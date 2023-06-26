#[contract]
mod Voting_contract {
    // core library imports
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use array::ArrayTrait;
    use box::BoxTrait;
    use clone::Clone;
    use array::ArrayTCloneImpl;

    // Contract storage
    struct Storage {
        admin: ContractAddress,
        election_participants: LegacyMap::<(u64, u64), ContractAddress>,
        election_no_is_used: LegacyMap::<u64, bool>,
        election_moderator: LegacyMap::<u64, ContractAddress>,
        election_is_active: LegacyMap::<u64, bool>,
        election_is_completed: LegacyMap::<u64, bool>,
        has_votted: LegacyMap::<ContractAddress, bool>,
        legitimate_candidate: LegacyMap::<(u64, ContractAddress), bool>,
        no_of_votes: LegacyMap::<(u64, ContractAddress), u128>
    }

    #[constructor]
    fn constructor() {
        admin::write(get_caller_address());
    }

    #[events]
    fn participants_registered(
        all_participans: Array::<ContractAddress>, no_of_winners: u64, election_no: u64
    ) {}

    #[events]
    fn vote_succesful(votter: ContractAddress, election_no: u256) {}


    #[external]
    fn Register_Participants(
        mut participants1: ContractAddress,
        mut participants2: ContractAddress,
        mut participants3: ContractAddress,
        mut election_no: u64
    ) {
        let election_no_check: bool = election_no_is_used::read(election_no);
        assert(election_no_check == false, 'Election number already used');
        election_moderator::write(election_no, get_caller_address());
        election_no_is_used::write(election_no, true);
        document_candidate(ref participants1, ref election_no, 1);
        document_candidate(ref participants2, ref election_no, 2);
        document_candidate(ref participants3, ref election_no, 3);
    }


    #[external]
    fn BeginElection(election_no: u64) {
        assert(election_moderator::read(election_no) == get_caller_address(), 'Not Moderator');
        assert(election_is_completed::read(election_no) == false, 'election already completed');
        assert(election_is_active::read(election_no) == false, 'election already active');
        election_is_active::write(election_no, true);
    }

    #[external]
    fn EndElection(election_no: u64) {
        assert(election_moderator::read(election_no) == get_caller_address(), 'Not Moderator');
        assert(election_is_completed::read(election_no) == false, 'election already completed');
        assert(election_is_active::read(election_no) == true, 'election already ended');
        election_is_active::write(election_no, false);
        election_is_completed::write(election_no, true);
    }

    #[external]
    fn Vote(election_no: u64, Candidate: ContractAddress) {
        assert(election_is_active::read(election_no) == true, 'Votting not active yet');
        assert(has_votted::read(get_caller_address()) == false, 'Already Votted');
        has_votted::write(get_caller_address(), true);
        let candidate_vote = no_of_votes::read((election_no, Candidate));
        no_of_votes::write((election_no, Candidate), candidate_vote + 1);
    }

    #[view]
    fn check_eligibility(candidate: ContractAddress, election_no: u64) -> bool {
        assert(election_no_is_used::read(election_no) == true, 'invalid election ID');
        legitimate_candidate::read((election_no, get_caller_address()))
    }

    #[view]
    fn displayWinner(election_no: u64) -> (ContractAddress, u128) {
        assert(election_no_is_used::read(election_no) == true, 'invalid election ID');
        let candidate1: ContractAddress = election_participants::read((election_no, 1));
        let candidate2: ContractAddress = election_participants::read((election_no, 2));
        let candidate3: ContractAddress = election_participants::read((election_no, 3));
        let Candidate1_vote = no_of_votes::read((election_no, candidate1));
        let Candidate2_vote = no_of_votes::read((election_no, candidate2));
        let Candidate3_vote = no_of_votes::read((election_no, candidate3));

        if (Candidate1_vote > Candidate2_vote & Candidate1_vote > Candidate3_vote) {
            return (candidate1, Candidate1_vote);
        } else if (Candidate2_vote > Candidate1_vote & Candidate2_vote > Candidate3_vote) {
            return (candidate2, Candidate2_vote);
        } else {
            return (candidate3, Candidate3_vote);
        }
    }

    #[view]
    fn get_all_candidates(election_no: u64) -> (ContractAddress, ContractAddress, ContractAddress) {
        assert(election_no_is_used::read(election_no) == true, 'invalid election ID');
        let candidate1: ContractAddress = election_participants::read((election_no, 1));
        let candidate2: ContractAddress = election_participants::read((election_no, 2));
        let candidate3: ContractAddress = election_participants::read((election_no, 3));
        (candidate1, candidate2, candidate3)
    }

    #[view]
    fn get_candidate_result(
        election_no: u64, candidate: ContractAddress
    ) -> (ContractAddress, u128) {
        assert(election_no_is_used::read(election_no) == true, 'invalid election ID');
        assert(legitimate_candidate::read((election_no, candidate)) == true, 'invalid candidate');
        let Candidate_vote = no_of_votes::read((election_no, candidate));
        (candidate, Candidate_vote)
    }

    // Internal Functions
    #[Internal]
    fn document_candidate(ref candidate: ContractAddress, ref election_no: u64, index: u64) {
        legitimate_candidate::write((election_no, candidate), true);
        election_participants::write((election_no, index), candidate);
    }
}
