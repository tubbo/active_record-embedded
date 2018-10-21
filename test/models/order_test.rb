# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = Order.new(
      items: [
        { sku: 'SKU123', quantity: 1 },
        { sku: 'SKU456', quantity: 2 }
      ],
      address: {
        name: 'Lester Tester',
        street_1: '123 Fake Street',
        city: 'Fakeadelphia',
        region: 'PA',
        country: 'US'
      }
    )
  end

  test 'embeds many items' do
    assert_kind_of ActiveRecord::Embedded::Relation, @order.items
    refute_empty @order.items
    assert_kind_of Item, @order.items.first
    assert_equal 'SKU123', @order.items.first.sku
  end

  test 'embeds one address' do
    refute_nil @order.address
    assert_kind_of Address, @order.address
    assert_equal 'Lester Tester', @order.address.name
  end

  test 'reads embedded data from the database' do
    order = orders(:one)
    item = order.items.first

    refute_empty order.items
    assert_kind_of Item, item
    assert_equal 'SKU123', item.sku
    assert_equal 1, item.quantity
    assert item.persisted?
  end

  test 'filter query on params' do
    order = orders(:one)
    items = order.items.where(quantity: 1)
    skus = items.map(&:sku)

    assert_kind_of ActiveRecord::Embedded::Relation, items
    refute_empty @order.items
    refute_empty items
    assert_equal 2, items.count
    assert_includes skus, 'SKU123'
    assert_includes skus, 'SKU999'
    refute_includes skus, 'SKU456'
  end

  test 'sort by param in ascending order' do
    order = orders(:one)
    items = order.items.order(sku: :asc)

    assert_kind_of ActiveRecord::Embedded::Relation, items
    assert_equal 'SKU123', items.first.sku
    assert_equal 'SKU999', items.last.sku
  end

  test 'sort by param in descending order' do
    order = orders(:one)
    items = order.items.order(sku: :desc)

    assert_kind_of ActiveRecord::Embedded::Relation, items
    assert_equal 'SKU999', items.first.sku
    assert_equal 'SKU123', items.last.sku
  end

  test 'failure to save' do
    order = orders(:one)
    item = order.items.build

    refute order.items.create.valid?

    assert_raises(ActiveRecord::RecordNotSaved) do
      item.save!
    end
    assert_raises(ActiveRecord::RecordNotSaved) do
      order.items.create!
    end

    item.quantity = 1

    assert item.save!
  end

  test 'reload' do
    order = orders(:one)
    item = order.items.first
    bogus = order.items.build

    assert item.reload
    assert_raises(ActiveRecord::RecordNotFound) { bogus.reload }
  end

  test 'dynamic attributes' do
    @order.create_customizations(foo: 'bar')
    customizations = @order.customizations
    customizations.baz = 'bat'

    assert_equal 'bar', customizations.foo
    assert_equal 'bat', customizations.baz
    assert customizations.save!
    assert customizations.reload
    assert_equal 'bat', customizations.baz
    assert_equal 'bar', customizations.foo
  end

  test 'prevent table scan' do
    assert_raises ActiveRecord::Embedded::Query::NoSolutionsError do
      orders(:one).items.find_by(quantity: 1)
    end
  end
end
