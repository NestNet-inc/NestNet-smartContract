#[starknet::contract]
pub mod Nestnet {
    use core::num::traits::Zero;
    use nestnet::interfaces::INestnet::INestnet;
    use nestnet::types::ProjectProposal;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, contract_address_const, get_caller_address};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        project_proposal: Map<(u64, ContractAddress), ProjectProposal>,
        user: Map<ContractAddress, User>,
        proposal_id: u64,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
        self.proposal_id.write(0);
    }

    #[derive(Drop, Serde, starknet::Event, starknet::Store)]
    pub struct User {
        pub isAuthenticated: bool,
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        ProjectProposal: ProjectProposal,
    }

    #[abi(embed_v0)]
    impl Nestnetimpl of INestnet<ContractState> {
        fn owner_proposal(
            ref self: ContractState,
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
        ) -> u64 {
            assert(name.is_non_zero(), 'Name cannot be empty');
            assert(description.is_non_zero(), 'description cannot be empty');
            assert(contract_signature.is_non_zero(), 'signature cannot be empty');
            assert(budget > 0 && budget >= amount_avaiable, 'Invalid budget');
            assert(amount_avaiable > 0, 'amount_avaiable cannot be zero');
            assert(percentage_left > 0, 'percentage_left cannot be zero');
            assert(percentage_used > 0, 'percentage_used cannot be zero');
            assert(Location.is_non_zero(), 'Location cannot be empty');
            assert(Type.is_non_zero(), 'Type cannot be empty');
            assert(size > 0, 'size cannot be zero');
            assert(Estimated_value > 0, 'Estimated_value cannot be zero');

            let owner = get_caller_address();
            let user = self.user.read(owner);
            let proposal_id = self.proposal_id.read();
            assert(user.isAuthenticated, 'User is not authenticated');

            let create_project_proposal = ProjectProposal {
                name: name,
                description: description,
                budget: budget,
                amount_avaiable: amount_avaiable,
                percentage_left: percentage_left,
                percentage_used: percentage_used,
                contract_signature: contract_signature,
                Location: Location,
                Type: Type,
                size: size,
                Estimated_value: Estimated_value,
            };
            self.project_proposal.write((proposal_id, owner), create_project_proposal);

            self
                .emit(
                    Event::ProjectProposal(
                        ProjectProposal {
                            name: name,
                            description: description,
                            budget: budget,
                            amount_avaiable: amount_avaiable,
                            percentage_left: percentage_left,
                            percentage_used: percentage_used,
                            contract_signature: contract_signature,
                            Location: Location,
                            Type: Type,
                            size: size,
                            Estimated_value: Estimated_value,
                        },
                    ),
                );

            proposal_id
        }
        fn get_proposal(
            self: @ContractState, proposer: ContractAddress, proposal_id: u64,
        ) -> ProjectProposal {
            self.project_proposal.read((proposal_id, proposer))
        }
        fn get_user(self: @ContractState, user: ContractAddress) -> User {
            self.user.read(user)
        }
        fn get_all_owner_proposal(ref self: ContractState) {
            let owner = self.owner.read();
            // Logic to get all owner proposals

        }
        fn authenticate_user(ref self: ContractState, user: ContractAddress) -> bool {
            assert(get_caller_address() == self.owner.read(), 'caller is unauthorized');
            let mut user_details = self.get_user(user);
            assert(!user_details.isAuthenticated, 'user is already authenticated');
            // Perform some authentication logic (checks)

            user_details.isAuthenticated = true;
            self.user.write(user, user_details);
            true
        }

        fn milestone(ref self: ContractState) {}
        fn milestone_checker(ref self: ContractState) {}
        fn fund_disposal(ref self: ContractState) {}
        fn investor_proposal(ref self: ContractState) {}
        fn get_all_investors_proposal(
            ref self: ContractState,
            name: felt252,
            description: felt252,
            amount: u256,
            contract_signature: felt252,
        ) {}
    }
}
