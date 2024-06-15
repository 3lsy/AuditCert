#[starknet::contract]
mod NFTAudit {
    // Import necessary components
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::option::OptionTrait;
    use starknet::traits::{TryInto, Into};
    use starknet::zeroable::Zeroable;
    use starknet::map::HashMap;

    // Define struct for storing audit information
    #[storage]
    struct AuditStorage {
        audit_info: HashMap::<u256, AuditCertification>,
        token_counter: u256,
    }

    // Struct to store audit certification information
    struct AuditCertification {
        commit: ByteArray,
        starknet_address: ContractAddress,
        audit_details: AuditDetails,
        audit_date: u64,
        auditor: ByteArray,
    }

    // Struct to store audit details
    struct AuditDetails {
        code_quality: CodeQuality,
        security_analysis: SecurityAnalysis,
    }

    // Struct to store code quality information
    struct CodeQuality {
        score: u64,
        issues_found: u64,
        issues_fixed: u64,
        recommendations: Vec::<ByteArray>,
    }

    // Struct to store security analysis information
    struct SecurityAnalysis {
        score: u64,
        vulnerabilities_found: u64,
        vulnerabilities_fixed: u64,
        recommendations: Vec::<ByteArray>,
    }

    // Event for token creation
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TokenCreated(u256),
    }

    // Implement the main contract functions
    #[contract]
    impl AuditStorage {
        // Constructor
        #[constructor]
        fn constructor(ref self, initial_token_counter: u256) {
            self.token_counter.write(initial_token_counter);
        }

        // Function to create NFT with audit information
        #[mutator]
        fn create_audit_certification(
            ref mut self,
            commit: ByteArray,
            starknet_address: ContractAddress,
            code_quality_score: u64,
            code_quality_issues_found: u64,
            code_quality_issues_fixed: u64,
            code_quality_recommendations: Vec::<ByteArray>,
            security_analysis_score: u64,
            security_analysis_vulnerabilities_found: u64,
            security_analysis_vulnerabilities_fixed: u64,
            security_analysis_recommendations: Vec::<ByteArray>,
            auditor: ByteArray,
        ) {
            let audit_details = AuditDetails {
                code_quality: CodeQuality {
                    score: code_quality_score,
                    issues_found: code_quality_issues_found,
                    issues_fixed: code_quality_issues_fixed,
                    recommendations: code_quality_recommendations,
                },
                security_analysis: SecurityAnalysis {
                    score: security_analysis_score,
                    vulnerabilities_found: security_analysis_vulnerabilities_found,
                    vulnerabilities_fixed: security_analysis_vulnerabilities_fixed,
                    recommendations: security_analysis_recommendations,
                },
            };

            let token_id = self.token_counter.read();
            self.token_counter.write(token_id + 1.into());

            let certification = AuditCertification {
                commit: commit,
                starknet_address: starknet_address,
                audit_details: audit_details,
                audit_date: now(),
                auditor: auditor,
            };

            self.audit_info.insert(token_id, certification);

            self.emit(TokenCreated(token_id));
        }

        // Function to get audit information by token ID
        #[view]
        fn get_audit_info(&self, token_id: u256) -> Option<AuditCertification> {
            self.audit_info.read(token_id)
        }
    }
}
