require "active_record"
require "minitest/autorun"

class Migrate < ActiveRecord::Migration
  self.verbose = false

  def up
    create_table(:accounts)
    create_table(:card_expirations, :id => false) do |t|
      t.references :account, :null => false
      t.string :payment_method_token, :null => false
      t.date :expiration_date
    end
  end
end

class Account < ActiveRecord::Base
  has_many :card_expirations
end

class CardExpiration < ActiveRecord::Base
end

class TestDuplicateAssociationBug < MiniTest::Unit::TestCase
  def setup
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    Migrate.new.up
  end

  # Only fails when card_expirations :id => false
  def test_association_create_creates_one_association
    today = Date.today
    account = Account.create!
    card_expiration = account.card_expirations.create!(
      :payment_method_token => "abcdefg",
      :expiration_date => today
    )

    assert_equal [card_expiration], account.card_expirations
  end
end
