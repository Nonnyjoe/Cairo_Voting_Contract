#[contract]
mod Voting_contract {
    // core library imports
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use array::ArrayTrait;

    // Contract storage
    struct Storage {
        admin: ContractAddress,
        election_participants: LegacyMap::<u64, ArrayTrait<ContractAddress>>,
        no_of_winners: LegacyMap::<u64, u64>,
        election_no_is_used: LegacyMap::<u64, bool>,
        legitimate_candidate: LegacyMap::<(u64, ContractAddress), bool>,
        no_of_votes: LegacyMap::<(u64, ContractAddress), u128>
    }

    #[constructor]
    fn constructor() {
        admin::write(get_caller_address());
    }

    #[events]
    fn participas_registered(
        participans: ArrayTrait::<ContractAddress>, no_of_winners: u256, election_no: u256
    ) {}

    #[events]
    fn vote_succesful(votter: ContractAddress, election_no: u256) {}

    #[external]
    fn Register_Participants(
        participants: ArrayTrait::<ContractAddress>, no_of_winners: u256, election_no: u64
    ) {
        let election_no_check: bool = election_no_is_used::read(election_no);
        assert(election_no_check == false, 'Election number already used');
        election_no_is_used::write(election_no, true);

        no_of_winners::write(election_no, no_of_winners);
        election_participants::write(election_no, participants);
        let no_of_candidates: usize = participants.len();
    }
    #[external]
    fn Vote(candidate: ArrayTrait::<ContractAddress>) -> bool {}

    #[view]
    fn check_eligibility() {}


    // Internal Functions

    fn document_candidate(ref candidate: ContractAddress) {
        legitimate_candidate::write((election_no, ContractAddress), true);
    }
}
