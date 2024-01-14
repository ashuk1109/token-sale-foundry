// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {SupraToken} from "./SupraToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface TokenSaleEvents {
    /** Events */
    event TokensPurchased(
        address indexed buyer,
        uint256 amount,
        uint256 tokens
    );
    event TokensRefunded(address indexed contributor, uint256 amount);
    event RemainingTokensDistributed(
        address indexed distributionAddress,
        uint256 amount
    );
}

/**
 * @title TokenSale
 * @author ashuk1109
 *
 * Token Sale Smart Contract for an ERC20 token.
 * The token sale will be conducted in two phases - Pre sale and Public Sale.
 */
contract TokenSale is Ownable, SupraToken, TokenSaleEvents {
    /** Errors */
    error TokenSale__EmergencyStopActive();
    error TokenSale__SaleNotActive();
    error TokenSale__SaleStillActive();
    error TokenSale__SaleCapExceeded();
    error TokenSale__MaxUserContributionCapReached();
    error TokenSale__InsufficientFunds();
    error TokenSale__SaleMinCapReached();
    error TokenSale__SaleMinCapNotReached();
    error TokenSale__ContributionOutOfRange();
    error TokenSale__NoContributionToRefund();
    error TokenSale__RefundNotAvailable();

    /** Type Declarations */
    struct SalePhase {
        uint8 id;
        uint256 cap;
        uint256 minContribution;
        uint256 maxContribution;
        uint256 startTime;
        uint256 endTime;
        uint256 totalContributed;
    }

    /** Variables */

    // Contract variables
    uint256 public immutable i_initialSupply;
    mapping(address => uint256) public s_presaleContributions;
    mapping(address => uint256) public s_publicSaleContributions;

    // SalePhase variables
    SalePhase public s_presale;
    SalePhase public s_publicSale;

    // Token variables
    uint256 public immutable i_minCap;
    uint256 public immutable i_tokenPrice;
    address public immutable i_distributionAddress;
    bool public s_presaleMinCapReached;
    bool public s_publicSaleMinCapReached;
    bool public s_emergencyStop;

    /** Modifiers */
    modifier notEmergencyStopped() {
        if (s_emergencyStop) revert TokenSale__EmergencyStopActive();
        _;
    }

    /** Functions */
    constructor(
        uint256 _tokenPrice,
        uint256 _presaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _presaleStartTime,
        uint256 _presaleEndTime,
        uint256 _publicSaleCap,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution,
        uint256 _publicSaleStartTime,
        uint256 _publicSaleEndTime,
        uint256 _minCap,
        address _distributionAddress,
        uint256 _totalSupply
    ) Ownable(msg.sender) SupraToken() {
        i_tokenPrice = _tokenPrice;

        s_presale = SalePhase({
            id: 0,
            cap: _presaleCap,
            minContribution: _presaleMinContribution,
            maxContribution: _presaleMaxContribution,
            startTime: _presaleStartTime,
            endTime: _presaleEndTime,
            totalContributed: 0
        });

        s_publicSale = SalePhase({
            id: 1,
            cap: _publicSaleCap,
            minContribution: _publicSaleMinContribution,
            maxContribution: _publicSaleMaxContribution,
            startTime: _publicSaleStartTime,
            endTime: _publicSaleEndTime,
            totalContributed: 0
        });

        i_minCap = _minCap;
        i_distributionAddress = _distributionAddress;

        _mint(msg.sender, _totalSupply);
    }

    /**
     * @dev Function for contributing to the presale or public sale.
     * Here we check if sale if active only then can someone contribute.
     * And then we call the internal contribution implementation to the correct
     * phase on basis of the timestamp.
     */
    function contribute() public payable notEmergencyStopped {
        uint256 amount = msg.value;
        if (!isPresaleActive() && !isPublicSaleActive()) {
            revert TokenSale__SaleNotActive();
        }

        if (isPresaleActive()) {
            contributeToPhase(
                s_presale,
                amount,
                s_presaleMinCapReached,
                s_presaleContributions
            );
        } else {
            contributeToPhase(
                s_publicSale,
                amount,
                s_publicSaleMinCapReached,
                s_publicSaleContributions
            );
        }
    }

    /**
     * @dev Internal function implementing the logic for contributing to either phase.
     * Conditions for contribution : amount should be valid, phase sale cap shouldn't exceed,
     * contributions shouldn't exceed max contribution per user.
     *
     * @param phase The phase to contribute to
     * @param amount The amount to contribute
     * @param minCapReachedFlag Whether the min cap has been reached
     * @param contributions The contributions mapping
     */
    function contributeToPhase(
        SalePhase storage phase,
        uint256 amount,
        bool minCapReachedFlag,
        mapping(address => uint256) storage contributions
    ) internal {
        if (amount < phase.minContribution || amount > phase.maxContribution) {
            revert TokenSale__ContributionOutOfRange();
        }

        if (phase.totalContributed + amount > phase.cap) {
            revert TokenSale__SaleCapExceeded();
        }

        if (contributions[msg.sender] + amount > phase.maxContribution) {
            revert TokenSale__MaxUserContributionCapReached();
        }

        contributions[msg.sender] += amount;
        phase.totalContributed += amount;

        _transfer(owner(), msg.sender, getTokenAmount(amount));
        emit TokensPurchased(msg.sender, amount, getTokenAmount(amount));

        if (!minCapReachedFlag && phase.totalContributed >= i_minCap) {
            if (phase.id == s_presale.id) {
                s_presaleMinCapReached = true;
            } else {
                s_publicSaleMinCapReached = true;
            }
        }
    }

    function isPresaleActive() public view returns (bool) {
        return
            block.timestamp >= s_presale.startTime &&
            block.timestamp <= s_presale.endTime;
    }

    function isPublicSaleActive() public view returns (bool) {
        return
            block.timestamp >= s_publicSale.startTime &&
            block.timestamp <= s_publicSale.endTime;
    }

    function emergencyStopSale() public onlyOwner {
        s_emergencyStop = true;
    }

    function resumeFromEmergencyStop() public onlyOwner {
        s_emergencyStop = false;
    }

    /**
     * @dev Function to distribute the remaining tokens to specified address.
     * Can only be called by the owner.
     */
    function distributeTokens() public onlyOwner {
        if (block.timestamp <= s_publicSale.endTime) {
            revert TokenSale__SaleStillActive();
        }

        if (!s_publicSaleMinCapReached) {
            revert TokenSale__SaleMinCapNotReached();
        }
        uint256 remainingTokens = balanceOf(owner());
        if (remainingTokens > 0) {
            _transfer(owner(), i_distributionAddress, remainingTokens);
        } else {
            revert TokenSale__InsufficientFunds();
        }

        emit RemainingTokensDistributed(i_distributionAddress, remainingTokens);
    }

    /**
     * @dev Function to claim refund if following conditions are met:
     * 1. No sale phase is currently active i.e. between pre sale end time and public sale
     *    start time for the pre sale phase refund and post public sale endtime for the
     *    public sale refund.
     * 2. Minimum cap for the given sale phase is not reached.
     * 3. The caller of the function has actually contributed to the sale phase.
     */
    function claimRefund() public notEmergencyStopped {
        if (isPresaleActive() || isPublicSaleActive()) {
            revert TokenSale__SaleStillActive();
        }

        if (s_publicSaleMinCapReached || s_presaleMinCapReached) {
            revert TokenSale__SaleMinCapReached();
        }

        uint256 refundAmount = 0;
        bool isPreSale = false;

        if (
            !s_presaleMinCapReached &&
            block.timestamp < s_publicSale.startTime &&
            block.timestamp > s_presale.endTime
        ) {
            refundAmount = s_presaleContributions[msg.sender];
            if (refundAmount <= 0) {
                revert TokenSale__NoContributionToRefund();
            }
            isPreSale = true;
        } else if (
            !s_publicSaleMinCapReached && block.timestamp > s_publicSale.endTime
        ) {
            refundAmount = s_publicSaleContributions[msg.sender];
            if (refundAmount <= 0) {
                revert TokenSale__NoContributionToRefund();
            }
        } else {
            revert TokenSale__RefundNotAvailable();
        }
        payable(msg.sender).transfer(refundAmount);
        _transfer(msg.sender, owner(), getTokenAmount(refundAmount));

        if (isPreSale) {
            s_presaleContributions[msg.sender] = 0;
        } else {
            s_publicSaleContributions[msg.sender] = 0;
        }

        emit TokensRefunded(msg.sender, refundAmount);
    }

    function getTokenAmount(uint256 etherAmount) public view returns (uint256) {
        return etherAmount / i_tokenPrice;
    }

    /** Getter Functions */
    function getPreSale()
        external
        view
        returns (uint8, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        return (
            s_presale.id,
            s_presale.cap,
            s_presale.minContribution,
            s_presale.maxContribution,
            s_presale.startTime,
            s_presale.endTime,
            s_presale.totalContributed
        );
    }

    function getPublicSale()
        external
        view
        returns (uint8, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        return (
            s_publicSale.id,
            s_publicSale.cap,
            s_publicSale.minContribution,
            s_publicSale.maxContribution,
            s_publicSale.startTime,
            s_publicSale.endTime,
            s_publicSale.totalContributed
        );
    }

    function getPreSaleContributions(
        address contributor
    ) external view returns (uint256) {
        return s_presaleContributions[contributor];
    }

    function getPublicSaleContributions(
        address contributor
    ) external view returns (uint256) {
        return s_publicSaleContributions[contributor];
    }
}
