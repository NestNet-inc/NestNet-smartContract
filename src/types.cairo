use starknet::ContractAddress;


#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct TokenInfo {
    pub address: ContractAddress,
    pub symbol: felt252,
    pub chain: felt252,
    pub balance: u256,
    pub price: u256,
}

#[derive(Drop, Serde, Copy, starknet::Event, starknet::Store)]
pub struct ProjectProposal {
    pub owner: ContractAddress,
    pub proposal_id: u64,
    pub description: felt252,
    pub budget: u256,
    pub name: felt252,
    pub amount_avaiable: u256,
    pub percentage_left: u8,
    pub percentage_used: u8,
    pub contract_signature: felt252,
    pub Location: felt252,
    pub Type: felt252,
    pub size: u256,
    pub Estimated_value: u256,
}

#[derive(Copy, Drop, Serde, PartialEq, starknet::Store)]
#[allow(starknet::store_no_default_variant)]
pub enum MilestoneStatus {
    Pending,
    InProgress,
    Completed,
    Verified,
    Rejected,
}

#[derive(Drop, Serde, Copy, starknet::Event, starknet::Store)]
pub struct Milestone {
    pub milestone_id: u64,
    pub proposal_id: u64,
    pub owner: ContractAddress,
    pub title: felt252,
    pub description: felt252,
    pub target_amount: u256,
    pub current_amount: u256,
    pub status: MilestoneStatus,
    pub deadline: u64,
    pub completion_proof: felt252,
    pub verifier: ContractAddress,
}

#[derive(Drop, Serde, Copy, starknet::Event)]
pub struct MilestoneStatusUpdated {
    pub milestone_id: u64,
    pub proposal_id: u64,
    pub old_status: MilestoneStatus,
    pub new_status: MilestoneStatus,
    pub updated_by: ContractAddress,
    pub timestamp: u64,
    pub proof_hash: felt252,
}

#[derive(Drop, Serde, Copy, starknet::Event)]
pub struct ProposalCompleted {
    pub proposal_id: u64,
    pub owner: ContractAddress,
    pub total_milestones: u64,
    pub completed_at: u64,
}

#[derive(Drop, Serde, Copy, starknet::Event)]
pub struct FundsReleased {
    pub milestone_id: u64,
    pub proposal_id: u64,
    pub recipient: ContractAddress,
    pub amount: u256,
    pub released_at: u64,
}
