%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.serialize import serialize_word

struct Card:
    member value: felt
    member color: felt
end

@storage_var
func deck(id:felt) -> (card:Card):
end

func _init_deck{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id, 
    value,
    color
) -> ():

    assert new_card = Card(value, color)

    if id == 51:
        deck.write(new_card, color)
        return
    end

    if id == 12:
        deck.write(new_card, color)
        return _init_deck(id+1, 0, D)
    end

    if id == 25:
        deck.write(new_card, color)
        return _init_deck(id+1, 0, C)
    end

    if id == 38:
        deck.write(new_card, color)
        return _init_deck(id+1, 0, S)
    end

    return _init_deck(id+1, value+1, color)
end

@external
func init_deck{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
)-> ():
    _init_deck(0, 1, "H")
    return
end

@external
func draw{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id: felt
)-> (card:Card):
    let (card) = deck.read(id) ## Sera "randomisé" et n'aura plus id j'ai laissé pour tester
    return (card=card)
end

