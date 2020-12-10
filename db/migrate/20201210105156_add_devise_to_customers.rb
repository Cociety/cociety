# frozen_string_literal: true

class AddDeviseToCustomers < ActiveRecord::Migration[6.1]
  def self.up
    change_table :customers do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
    end

    get_all_customer_emails = <<-SQL
      SELECT
        *
      from
        customer_emails;
    SQL

    ActiveRecord::Base.connection.execute(get_all_customer_emails).each do |e|
      customer = Customer.find(e['customer_id'])
      customer.email = e['email']
      customer.save
      customer.confirm if e['is_verified']
      customer.save
    end

    add_index :customers, :email,                unique: true
    add_index :customers, :reset_password_token, unique: true
    add_index :customers, :confirmation_token,   unique: true
    add_index :customers, :unlock_token,         unique: true

    drop_table :customer_emails
  end

  def self.down
    create_table :customer_emails, id: :uuid do |t|
      t.string :email
      t.references :customer, null: false, foreign_key: true, type: :uuid
      t.boolean :is_verified, null: false, default: false
      t.boolean :is_default, null: false, default: false

      t.timestamps
    end
    add_index :customer_emails, :email, unique: true
    add_index :customer_emails, %i[customer_id is_default], unique: true, where: 'is_default'

    Customer.all.each do |c|
      insert_customer_email = <<-SQL
        INSERT INTO
          customer_emails (email, customer_id, is_verified, is_default, created_at, updated_at)
        VALUES
          (:email, :customer_id, :is_verified, :is_default, NOW(), NOW())
      SQL
      ActiveRecord::Base.connection.select_one(
        ActiveRecord::Base.sanitize_sql(
          [insert_customer_email, {
            email:       c.email? ? c.email : c.unconfirmed_email,
            customer_id: c.id,
            is_verified: c.confirmed?,
            is_default:  true
          }]
        )
      )
    end

    change_table :customers do |t|
      t.remove_index :email
      t.remove_index :reset_password_token
      t.remove_index :confirmation_token
      t.remove_index :unlock_token

      ## Database authenticatable
      t.remove :email
      t.remove :encrypted_password

      ## Recoverable
      t.remove :reset_password_token
      t.remove :reset_password_sent_at

      ## Rememberable
      t.remove :remember_created_at

      ## Trackable
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip

      ## Confirmable
      t.remove :confirmation_token
      t.remove :confirmed_at
      t.remove :confirmation_sent_at
      t.remove :unconfirmed_email

      ## Lockable
      t.remove :failed_attempts
      t.remove :unlock_token
      t.remove :locked_at
    end
  end
end
