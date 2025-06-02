use nestnet::nestnet::Nestnet::User;
use nestnet::types::{Milestone, MilestoneStatus, ProjectProposal};
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
    fn get_all_proposals_by_owner(
        self: @TContractState, proposer: ContractAddress,
    ) -> Option<Array<ProjectProposal>>;
    fn get_proposal(
        self: @TContractState, proposer: ContractAddress, proposal_id: u64,
    ) -> Option<ProjectProposal>;
    fn get_all_owner_proposal(ref self: TContractState);
    fn authenticate_user(ref self: TContractState, user: ContractAddress) -> bool;
    fn get_user(self: @TContractState, user: ContractAddress) -> User;
    fn fund_disposal(ref self: TContractState);
    fn investor_proposal(ref self: TContractState);
    fn get_all_investors_proposal(
        ref self: TContractState,
        name: felt252,
        description: felt252,
        amount: u256,
        contract_signature: felt252,
    );

    fn create_milestone(
        ref self: TContractState,
        proposal_id: u64,
        title: felt252,
        description: felt252,
        target_amount: u256,
        deadline: u64,
    ) -> u64;

    fn milestone_checker(self: @TContractState, milestone_id: u64) -> Option<Milestone>;

    fn update_milestone_status(
        ref self: TContractState,
        milestone_id: u64,
        new_status: MilestoneStatus,
        completion_proof: felt252,
    ) -> bool;
}

