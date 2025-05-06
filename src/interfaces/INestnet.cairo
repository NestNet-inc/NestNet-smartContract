use nestnet::nestnet::Nestnet::User;
use nestnet::types::ProjectProposal;
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
        Location: felt252,
        Type: felt252,
        size: u256,
        Estimated_value: u256,
    ) -> u64;
    fn get_proposal(
        self: @TContractState, proposer: ContractAddress, proposal_id: u64,
    ) -> ProjectProposal;
    fn get_all_owner_proposal(ref self: TContractState);
    fn authenticate_user(ref self: TContractState, user: ContractAddress) -> bool;
    fn get_user(self: @TContractState, user: ContractAddress) -> User;
    fn milestone(ref self: TContractState);
    fn milestone_checker(ref self: TContractState);
    fn fund_disposal(ref self: TContractState);
    fn investor_proposal(ref self: TContractState);
    fn get_all_investors_proposal(
        ref self: TContractState,
        name: felt252,
        description: felt252,
        amount: u256,
        contract_signature: felt252,
    );
}

