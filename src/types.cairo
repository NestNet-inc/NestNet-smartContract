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
