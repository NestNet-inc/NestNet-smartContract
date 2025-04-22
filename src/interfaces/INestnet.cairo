use starknet::ContractAddress;


#[starknet::interface]
pub trait INestnet<TContractState> {
    fn owner_proposal(
        ref self: TContractState,
        name: felt252,
        description: felt252,
        budget: u256,
        amount_avaiable: u256,
        percentage_left: u8,
        percentage_used: u8,
        contract_signature: felt252,
    );
    fn get_all_owner_proposal();

    fn milestone();
    fn milestone_checker() 
    fn fund_disposal();
    fn investor_proposal();
    fn get_all_investors_proposal(
        ref self: TContractState,
        name: felt252,
        description: felt252,
        amount: u256,
        contract_signature: felt252,
    )


}

