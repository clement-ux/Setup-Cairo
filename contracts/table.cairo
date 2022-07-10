%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import (
    assert_le,
    assert_not_zero,
    assert_not_equal,
    unsigned_div_rem,
)

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
end

struct River:
    member flop1 : Card
    member flop2 : Card
    member flop3 : Card
    member turn : Card
    member river : Card
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
func balance_round() -> (res : felt):
end

@storage_var
func river_round() -> (river : River):
end

@storage_var
func balance_player(user : felt) -> (res : felt):
end

@storage_var
func balance_player_round(user : felt) -> (res : felt):
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
func players() -> (table : Table):
end

@storage_var
func is_ready_to_start() -> (table : Table):
end

@storage_var
func _seed() -> (res : felt):
end

# ##### Timeline Variables ########
@storage_var
func tl_started() -> (res : felt):
end
@storage_var
func tl_player_drawn() -> (res : felt):
end
@storage_var
func tl_flop() -> (res : felt):
end

# ##### For each sub-round #######
@storage_var
func is_turn_to() -> (res : felt):
end

# ########################
# #     Constructor     ##
# ########################
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (sender_address) = get_caller_address()
    owner.write(sender_address)
    _seed.write(12)
    return ()
end

# #########################
# #        External      ##
# #########################

@external
func init_deck{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    _init_deck(0, 2, 'H')
    return ()
end

@external
func caving{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : felt):
    alloc_locals
    let (local sender_address) = get_caller_address()

    let (table : Table) = players.read()

    if table.player_1 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        players.write(
            Table(sender_address, table.player_2, table.player_3, table.player_4, table.player_5)
        )
        balance_player.write(sender_address, amount)
        is_player.write(sender_address, 1)
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if table.player_2 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        players.write(
            Table(table.player_1, sender_address, table.player_3, table.player_4, table.player_5)
        )
        balance_player.write(sender_address, amount)
        is_player.write(sender_address, 1)
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if table.player_3 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        players.write(
            Table(table.player_1, table.player_2, sender_address, table.player_4, table.player_5)
        )
        balance_player.write(sender_address, amount)
        is_player.write(sender_address, 1)
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if table.player_4 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        players.write(
            Table(table.player_1, table.player_2, table.player_3, sender_address, table.player_5)
        )
        balance_player.write(sender_address, amount)
        is_player.write(sender_address, 1)
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if table.player_5 == 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr

        players.write(
            Table(table.player_1, table.player_2, table.player_3, table.player_4, sender_address)
        )
        balance_player.write(sender_address, amount)
        is_player.write(sender_address, 1)
        return ()
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    return ()
end

@external
func player_ready_round{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    alloc_locals
    let (local sender_address) = get_caller_address()
    let (_is_player) = is_player.read(sender_address)
    let (player : Table) = players.read()
    let (ready : Table) = is_ready_to_start.read()
    let (_tl_started : felt) = tl_started.read()

    assert_not_equal(_tl_started, 1)
    assert_not_zero(_is_player)

    if sender_address == player.player_1:
        is_ready_to_start.write(
            Table(1, ready.player_2, ready.player_3, ready.player_4, ready.player_5)
        )
        return ()
    end

    if sender_address == player.player_2:
        is_ready_to_start.write(
            Table(ready.player_1, 1, ready.player_3, ready.player_4, ready.player_5)
        )
        return ()
    end

    if sender_address == player.player_3:
        is_ready_to_start.write(
            Table(ready.player_1, ready.player_2, 1, ready.player_4, ready.player_5)
        )
        return ()
    end

    if sender_address == player.player_4:
        is_ready_to_start.write(
            Table(ready.player_1, ready.player_2, ready.player_3, 1, ready.player_5)
        )
        return ()
    end

    if sender_address == player.player_5:
        is_ready_to_start.write(
            Table(ready.player_1, ready.player_2, ready.player_3, ready.player_5, 1)
        )
        return ()
    end

    let (_start_round : felt) = start_round()
    if _start_round == 0:
        return ()
    else:
        tl_started.write(1)
        return ()
    end
end

@external
func start_round{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    alloc_locals
    let (player : Table) = players.read()
    let (ready : Table) = is_ready_to_start.read()
    local sum : felt = 0

    if player.player_5 == 0:
        sum = sum + 1
    else:
        if ready.player_5 == 1:
            sum = sum + 1
        else:
            return (0)
        end
    end

    if player.player_4 == 0:
        sum = sum + 1
    else:
        if ready.player_4 == 1:
            sum = sum + 1
        else:
            return (0)
        end
    end

    if player.player_3 == 0:
        sum = sum + 1
    else:
        if ready.player_3 == 1:
            sum = sum + 1
        else:
            return (0)
        end
    end

    if player.player_2 == 0:
        sum = sum + 1
    else:
        if ready.player_2 == 1:
            sum = sum + 1
        else:
            return (0)
        end
    end

    if player.player_1 == 0:
        sum = sum + 1
    else:
        if ready.player_1 == 1:
            sum = sum + 1
        else:
            return (0)
        end
    end

    if sum == 5:
        return (1)
    else:
        return (0)
    end
end

@external
func draw_hand_table{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
) -> ():
    alloc_locals
    let (_tl_started) = tl_started.read()
    let (_tl_player_drawn) = tl_player_drawn.read()

    assert_not_equal(_tl_started, 0)
    assert_not_equal(_tl_player_drawn, 1)

    let (player : Table) = players.read()

    if player.player_1 != 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        draw_hand(player.player_1)
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if player.player_2 != 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        draw_hand(player.player_2)
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if player.player_3 != 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        draw_hand(player.player_3)
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if player.player_4 != 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        draw_hand(player.player_4)
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    if player.player_5 != 0:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
        draw_hand(player.player_5)
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    tl_player_drawn.write(1)
    is_turn_to.write(player.player_1)

    return ()
end

@external
func bet{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : felt) -> ():
    alloc_locals
    let (local sender_address) = get_caller_address()
    let (_tl_player_drawn) = tl_player_drawn.read()

    assert_not_equal(_tl_player_drawn, 0)

    let (bp) = balance_player.read(sender_address)
    let (br) = balance_round.read()
    let (bpr) = balance_player_round.read(sender_address)
    assert_le(amount, bp)

    balance_player.write(sender_address, bp - amount)
    balance_player_round.write(sender_address, bpr + amount)
    balance_round.write(br + amount)
    return ()
end

@external
func draw_flop{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    alloc_locals
    let card1 : Card = draw()
    let card2 : Card = draw()
    let card3 : Card = draw()
    let river : River = river_round.read()

    river_round.write(River(card1, card2, card3, river.turn, river.river))
    return ()
end

@external
func draw_turn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    alloc_locals
    let turn : Card = draw()
    let river : River = river_round.read()

    river_round.write(River(river.flop1, river.flop2, river.flop3, turn, river.river))
    return ()
end

@external
func draw_river{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> ():
    alloc_locals
    let card : Card = draw()
    let river : River = river_round.read()

    river_round.write(River(river.flop1, river.flop2, river.flop3, river.turn, card))

    return ()
end

@external
func get_winner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    return (0)
end

@external
func send_reward{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    let (winner) = get_winner()
    let (br) = balance_round.read()
    let (bp) = balance_player.read(winner)

    balance_player.write(winner, bp + br)
    balance_round.write(0)

    round_end()

    return ()
end

@external
func round_end{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> ():
    return ()
end

# #########################
# #        Internal      ##
# #########################
func _init_deck{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt, value : felt, color : felt
) -> ():
    deck.write(id, Card(value, color))

    if id == 51:
        return ()
    end

    if id == 12:
        return _init_deck(id + 1, 2, 'D')
    end

    if id == 25:
        return _init_deck(id + 1, 2, 'C')
    end

    if id == 38:
        return _init_deck(id + 1, 2, 'S')
    end
    return _init_deck(id + 1, value + 1, color)
end

func draw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (card : Card):
    alloc_locals
    local _randint = 10  # Need to implement with randint(51)
    let (new_card) = deck.read(_randint)  # # Sera "randomisé" et n'aura plus _randint j'ai laissé pour tester

    if new_card.value == 0:
        return draw()
    end
    deck.write(_randint, Card(0, '0'))
    return (new_card)
end

func draw_hand{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> ():
    alloc_locals
    # let (local sender_address) = get_caller_address()
    let (_is_player) = is_player.read(address)

    if _is_player == 0:
        return ()
    end

    let hand : Hand = hand_player.read(address)

    if hand.init == 1:
        return ()
    end

    let card1 : Card = draw()
    let card2 : Card = draw()

    hand_player.write(address, Hand(card1, card2, 1))
    return ()
end

func randint{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
    hash_ptr : HashBuiltin*,
    bitwise_ptr : BitwiseBuiltin*,
}(max : felt) -> (number : felt):
    alloc_locals
    let (seed) = _seed.read()
    let (result) = hash2(x=max * seed, y=max + seed)
    let (result) = bitwise_and(result, 1023)
    let (_, number) = unsigned_div_rem(result, max)
    _seed.write(seed + 1)
    return (number)
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
func get_balance_round{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    res : felt
):
    let (res) = balance_round.read()
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
func get_hand_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    hand : Hand
):
    let (sender_address) = get_caller_address()
    let (res) = hand_player.read(sender_address)
    return (hand=res)
end

@view
func get_players{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    table : Table
):
    let (res) = players.read()
    return (table=res)
end
