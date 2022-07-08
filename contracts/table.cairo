%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.serialize import serialize_word

# ########################
# #      Structure      ##
# ########################

struct Card:
    member value : felt
    member color : felt
end

struct Hand:
    member card1 : Card
    member card2 : Card
    member init : felt
end

struct Table:
    member player_1 : felt
    member player_2 : felt
    member player_3 : felt
    member player_4 : felt
    member player_5 : felt
    member player_6 : felt
end
# ########################
# #      Variables      ##
# ########################

@storage_var
func deck(id : felt) -> (card : Card):
end

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
func hand_player(user : felt) -> (hand : Hand):
end

@storage_var
func big_blind() -> (res : felt):
end

@storage_var
func small_blind() -> (res : felt):
end

@storage_var
func table() -> (table : Table):
end

# ########################
# #     Constructor     ##
# ########################
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (sender_address) = get_caller_address()
    owner.write(sender_address)
    return ()
end

# #########################
# #         View         ##
# #########################
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

@view
func sender{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (res : felt):
    let (sender_address) = get_caller_address()
    return (res=sender_address)
end

@view
func get_deck{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (
    card : Card
):
    let (res) = deck.read(id)
    return (card=res)
end

@view
func get_hand_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (hand : Hand):
    let (res) = hand_player.read(address)
    return (hand=res)
end

# #########################
# #        External      ##
# #########################

@external
func init_deck{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    _init_deck(0, 1, 'H')
    return ()
end

@external
func caving{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : felt):
    alloc_locals
    let (local sender_address) = get_caller_address()
    balance_player.write(sender_address, amount)
    is_player.write(sender_address, 1)

    let (tables : Table) = table.read()

    if tables.player_1 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        table.write(
            Table(sender_address, tables.player_2, tables.player_3, tables.player_4, tables.player_5, tables.player_6),
        )
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if tables.player_2 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        table.write(
            Table(tables.player_1, sender_address, tables.player_3, tables.player_4, tables.player_5, tables.player_6),
        )
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if tables.player_3 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        table.write(
            Table(tables.player_1, tables.player_2, sender_address, tables.player_4, tables.player_5, tables.player_6),
        )
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    return ()
end

@external
func draw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (
    card : Card
):
    let (new_card) = deck.read(id)  # # Sera "randomisé" et n'aura plus id j'ai laissé pour tester

    if new_card.value == 0:
        if id == 51:
            return draw(0)
        end
        return draw(id + 1)
    end
    deck.write(id, Card(0, '0'))
    return (new_card)
end

@external
func draw_hand{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> ():
    alloc_locals
    let (local sender_address) = get_caller_address()
    let hand : Hand = hand_player.read(sender_address)

    if hand.init == 1:
        return ()
    end

    let card1 : Card = draw(id)
    let card2 : Card = draw(id)

    hand_player.write(sender_address, Hand(card1, card2, 1))
    return ()
end

func _init_deck{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt, value : felt, color : felt
) -> ():
    deck.write(id, Card(value, color))

    if id == 51:
        return ()
    end

    if id == 12:
        return _init_deck(id + 1, 0, 'D')
    end

    if id == 25:
        return _init_deck(id + 1, 0, 'C')
    end

    if id == 38:
        return _init_deck(id + 1, 0, 'S')
    end
    return _init_deck(id + 1, value + 1, color)
end

# @external
# Main des joueurs
# River
# Calculateur de mains
# Update Balance
