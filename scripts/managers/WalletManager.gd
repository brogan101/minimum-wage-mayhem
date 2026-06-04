extends Node
## WalletManager (Autoload) handles the money.

signal balance_changed(new_balance)

var balance: float = 0.0

func add_money(amount: float):
	balance += amount
	balance_changed.emit(balance)
	print("Wallet: $", balance)

func spend_money(amount: float) -> bool:
	if balance >= amount:
		balance -= amount
		balance_changed.emit(balance)
		return true
	print("Insufficient funds! You are broke.")
	return false
