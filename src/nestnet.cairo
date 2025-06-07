#[starknet::contract]
pub mod Nestnet {
    use core::num::traits::Zero;
    use nestnet::interfaces::INestnet::INestnet;
    use nestnet::types::{
        FundsReleased, Milestone, MilestoneStatus, MilestoneStatusUpdated, ProjectProposal,
        ProposalCompleted,
    };
    use starknet::storage::{
        Map, MutableVecTrait, StorageMapReadAccess, StorageMapWriteAccess, StoragePathEntry,
        StoragePointerReadAccess, StoragePointerWriteAccess, Vec, VecTrait,
    };
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        owner_proposal: Vec<ProjectProposal>,
        user: Map<ContractAddress, User>,
        proposal_id: u64,
        milestones: Map<u64, Milestone>,
        milestone_counter: u64,
        proposal_milestones: Map<u64, Vec<u64>> // proposal_id -> milestone_ids
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
        MilestoneStatusUpdated: MilestoneStatusUpdated,
        ProposalCompleted: ProposalCompleted,
        FundsReleased: FundsReleased,
    }

    // Private helper functions
    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn _is_valid_transition(
            self: @ContractState, from: MilestoneStatus, to: MilestoneStatus,
        ) -> bool {
            match from {
                MilestoneStatus::Pending => {
                    match to {
                        MilestoneStatus::InProgress => true,
                        MilestoneStatus::Rejected => true,
                        _ => false,
                    }
                },
                MilestoneStatus::InProgress => {
                    match to {
                        MilestoneStatus::Completed => true,
                        MilestoneStatus::Rejected => true,
                        _ => false,
                    }
                },
                MilestoneStatus::Completed => {
                    match to {
                        MilestoneStatus::Verified => true,
                        MilestoneStatus::Rejected => true,
                        _ => false,
                    }
                },
                _ => false // Terminal states cannot transition
            }
        }

        fn _handle_milestone_completion(ref self: ContractState, milestone_id: u64) {
            let milestone = self.milestones.read(milestone_id);

            // 1. Check if all milestones for this proposal are verified
            let proposal_milestones = self.proposal_milestones.entry(milestone.proposal_id);
            let mut all_milestones_verified = true;
            let mut total_milestones = 0;
            let mut verified_count = 0;

            let mut i = 0;
            let milestone_count = proposal_milestones.len();
            while i != milestone_count {
                let mid = proposal_milestones.at(i).read();
                let m = self.milestones.read(mid);
                total_milestones += 1;

                if m.status == MilestoneStatus::Verified {
                    verified_count += 1;
                } else {
                    all_milestones_verified = false;
                }
                i += 1;
            }

            // 2. Update proposal progress (unused for now but kept for future use)
            let _progress_percentage: u64 = if total_milestones > 0 {
                (verified_count * 100_u64) / total_milestones
            } else {
                0_u64
            };

            // 3. If all milestones are verified, mark proposal as completed
            if all_milestones_verified && total_milestones > 0 {
                // Find and update the proposal
                let mut proposal_index = 0;
                let proposal_count = self.owner_proposal.len();

                while proposal_index != proposal_count {
                    let mut proposal = self.owner_proposal.at(proposal_index).read();
                    if proposal.proposal_id == milestone.proposal_id {
                        // Update proposal status to completed (100% progress)
                        proposal.percentage_used = 100;
                        proposal.percentage_left = 0;
                        self.owner_proposal.at(proposal_index).write(proposal);

                        // Emit proposal completion event
                        self
                            .emit(
                                Event::ProposalCompleted(
                                    ProposalCompleted {
                                        proposal_id: milestone.proposal_id,
                                        owner: proposal.owner,
                                        total_milestones: total_milestones.into(),
                                        completed_at: starknet::get_block_timestamp(),
                                    },
                                ),
                            );
                        break;
                    }
                    proposal_index += 1;
                }
            }

            // 4. Release milestone funds to the milestone owner
            // Emit fund release event (in real implementation, actual fund transfer would occur)
            self
                .emit(
                    Event::FundsReleased(
                        FundsReleased {
                            milestone_id,
                            proposal_id: milestone.proposal_id,
                            recipient: milestone.owner,
                            amount: milestone.target_amount,
                            released_at: starknet::get_block_timestamp(),
                        },
                    ),
                );
            // 5. Additional cascade effects can be added here:
        // - Notify investors
        // - Update reputation scores
        // - Trigger next phase milestones
        }
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

            let create_owner_proposal = ProjectProposal {
                owner: owner,
                proposal_id: proposal_id,
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
            self.owner_proposal.push(create_owner_proposal);

            self
                .emit(
                    Event::ProjectProposal(
                        ProjectProposal {
                            owner: owner,
                            proposal_id: proposal_id,
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
        ) -> Option<ProjectProposal> {
            let owner_proposal_count: u64 = self.owner_proposal.len();

            if owner_proposal_count == 0 {
                return Option::None;
            }

            // Iterate through all proposals
            let mut i: u64 = 0;
            while i != owner_proposal_count {
                // Get the proposal at index i
                let proposal: ProjectProposal = self.owner_proposal.at(i).read();

                // Check if this is the proposal we're looking for
                if proposal.proposal_id == proposal_id && proposal.owner == proposer {
                    return Option::Some(proposal);
                }

                i += 1;
            }

            // If proposal not found, return None
            Option::None
        }

        fn get_all_proposals_by_owner(
            self: @ContractState, proposer: ContractAddress,
        ) -> Option<Array<ProjectProposal>> {
            let owner_proposal_count: u64 = self.owner_proposal.len();

            if owner_proposal_count == 0 {
                return Option::None;
            }

            let mut matching_proposals: Array<ProjectProposal> = ArrayTrait::new();

            // Iterate through all proposals
            let mut i: u64 = 0;
            while i != owner_proposal_count {
                // Get the proposal at index i
                let proposal: ProjectProposal = self.owner_proposal.at(i).read();

                // Check if this proposal belongs to the specified proposer
                if proposal.owner == proposer {
                    matching_proposals.append(proposal);
                }

                i += 1;
            }

            // Return None if no matching proposals were found
            if matching_proposals.len() == 0 {
                return Option::None;
            }

            // Return the array of matching proposals
            Option::Some(matching_proposals)
        }

        fn get_user(self: @ContractState, user: ContractAddress) -> User {
            self.user.read(user)
        }
        fn get_all_owner_proposal(ref self: ContractState) {
            let _owner = self.owner.read();
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

        fn create_milestone(
            ref self: ContractState,
            proposal_id: u64,
            title: felt252,
            description: felt252,
            target_amount: u256,
            deadline: u64,
        ) -> u64 {
            let caller = get_caller_address();
            let user = self.user.read(caller);
            assert(user.isAuthenticated, 'User not authenticated');

            let milestone_id = self.milestone_counter.read() + 1;
            self.milestone_counter.write(milestone_id);

            let milestone = Milestone {
                milestone_id,
                proposal_id,
                owner: caller,
                title,
                description,
                target_amount,
                current_amount: 0,
                status: MilestoneStatus::Pending,
                deadline,
                completion_proof: 0,
                verifier: 0.try_into().unwrap(),
            };

            self.milestones.write(milestone_id, milestone);

            // Add milestone to proposal's milestone list
            let proposal_milestones = self.proposal_milestones.entry(proposal_id);
            proposal_milestones.push(milestone_id);

            milestone_id
        }

        fn milestone_checker(self: @ContractState, milestone_id: u64) -> Option<(Milestone, u64, bool)> {
            // Check if milestone exists
            let milestone = self.milestones.read(milestone_id);
            if milestone.milestone_id == 0 {
                return Option::None;
            }

            // Get proposal milestones to calculate progress
            let proposal_milestones = self.proposal_milestones.entry(milestone.proposal_id);
            let mut total_milestones = 0;
            let mut completed_milestones = 0;

            let mut i = 0;
            let milestone_count = proposal_milestones.len();
            while i != milestone_count {
                let mid = proposal_milestones.at(i).read();
                let m = self.milestones.read(mid);
                total_milestones += 1;

                if m.status == MilestoneStatus::Verified || m.status == MilestoneStatus::Completed {
                    completed_milestones += 1;
                }
                i += 1;
            }

            // Calculate progress percentage (0-100)
            let progress_percentage = if total_milestones > 0 {
                (completed_milestones * 100_u64) / total_milestones
            } else {
                0_u64
            };

            // Check if milestone is on track (not past deadline)
            let current_time = starknet::get_block_timestamp();
            let is_on_track = current_time <= milestone.deadline;

            Option::Some((milestone, progress_percentage, is_on_track))
        }

        fn update_milestone_status(
            ref self: ContractState,
            milestone_id: u64,
            new_status: MilestoneStatus,
            completion_proof: felt252,
        ) -> bool {
            let caller = get_caller_address();

            // Check if milestone exists by checking if ID is within valid range
            assert(milestone_id <= self.milestone_counter.read(), 'Milestone does not exist');
            assert(milestone_id > 0, 'Milestone does not exist');

            // Get the milestone (now safe to read since we validated it exists)
            let milestone = self.milestones.read(milestone_id);

            // Authorization checks
            let user = self.user.read(caller);
            let is_owner = caller == milestone.owner;
            let is_contract_owner = caller == self.owner.read();
            let is_authenticated = user.isAuthenticated;

            assert(is_owner || is_contract_owner, 'Unauthorized caller');
            assert(is_authenticated, 'User not authenticated');

            // Validate status transitions using state machine logic
            let old_status = milestone.status;
            assert(self._is_valid_transition(old_status, new_status), 'Invalid status transition');

            // Status-specific validations
            match new_status {
                MilestoneStatus::Completed => {
                    assert(completion_proof.is_non_zero(), 'Completion proof required');
                    assert(
                        milestone.current_amount >= milestone.target_amount, 'Target not reached',
                    );
                },
                MilestoneStatus::Verified => {
                    assert(old_status == MilestoneStatus::Completed, 'Must be completed first');
                    assert(is_contract_owner, 'Only contract owner can verify');
                },
                MilestoneStatus::Rejected => {
                    assert(is_contract_owner, 'Only contract owner can reject');
                },
                _ => {},
            }

            // Update milestone
            let mut updated_milestone = milestone;
            updated_milestone.status = new_status;
            updated_milestone.completion_proof = completion_proof;
            self.milestones.write(milestone_id, updated_milestone);

            // Emit event
            self
                .emit(
                    Event::MilestoneStatusUpdated(
                        MilestoneStatusUpdated {
                            milestone_id,
                            proposal_id: milestone.proposal_id,
                            old_status,
                            new_status,
                            updated_by: caller,
                            timestamp: starknet::get_block_timestamp(),
                            proof_hash: completion_proof,
                        },
                    ),
                );

            // Trigger cascade effects
            if new_status == MilestoneStatus::Verified {
                self._handle_milestone_completion(milestone_id);
            }
            true
        }

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
