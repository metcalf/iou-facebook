class SimplifyPayments < ActiveRecord::Migration
  def self.up
    add_column "payments", "amount", :decimal, :precision => 9, :scale => 2, :null => false
    execute "UPDATE payments, (SELECT payment_id, sum(amount) FROM debt_payments GROUP BY payment_id) as sums SET payments.amount = sums.`sum(amount)` WHERE payments.id = payment_id"
    drop_table "debt_payments"
    
    remove_column "debts", "completed"
    remove_column "user_debts", "is_outstanding"
  end
end