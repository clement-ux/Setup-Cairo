%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.serialize import serialize_word

# Define a storage variable.
@storage_var
func owner() -> (res : felt):
end

@storage_var
func balanceTable() -> (res : felt):
end

@storage_var
func balance_player(user : felt) -> (res : felt):
end

@storage_var
func is_player(user : felt) -> (bool : felt):
end

@storage_var
func big_blind() -> (res : felt):
end

@storage_var
func small_blind() -> (res : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (sender_address) = get_caller_address()
    owner.write(sender_address)
    return ()
end

@external
func caving{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    amount : felt, address : felt
):
    let (sender_address) = get_caller_address()
    owner.write(sender_address)
    balance_player.write(address, amount)
    is_player.write(address, 1)
    return ()
end

# Returns the current balance.
@view
func get_owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (res) = owner.read()
    return (res=res)
end

@view
func get_balance_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (res : felt):
    let (res) = balance_player.read(address)
    return (res=res)
end

@view
func get_is_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (res : felt):
    let (res) = is_player.read(address)
    return (res=res)
end

@external 
# Main des joueurs
# River
# Calculateur de mains
# Update Balance