// SPDX-License-Identifier: MIT
// An example of a consumer contract that directly pays for each request.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract VRFv2DirectFundingConsumer is
    VRFV2WrapperConsumerBase,
    ConfirmedOwner
{
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    mapping(uint256 => bool) public selectedIndex;

    uint256 public called = 0;
    uint256 public sampleSize = 10; 
    address[] public sample;
 address[] public members = [
    address(0x354Af718783c01a2592B1D479575A8fa14521cD9),
address(0x6Bc8417F1716dE63445ff73B6eB99Ba949C8b0b1),
address(0x74725834faFd09e55E8F5b2e6685f376b7D5Ccf1),
address(0xCd0D4CDb238Eec15Fcf4ff9d13d5a59051E507D7),
address(0x712054225Ac08595422b0BEe4c386Bd420F7e166),
address(0x9327d668b6428c66EF9d52432531aFb4CD0Ce83f),
address(0xC1f8344792F33722c39db965b257C9f3E0a4a320),
address(0x468Fd68b81475Ac46D00f491bFA52ef8AAa17e97),
address(0xbE533f7B30E2283B50E2d5Fd3e2DBa765c2fb013),
address(0x2C0843C7281eC77160479681c882884fA4830B29),
address(0xcf8cf5dF28dB4F4e8376C90D8CEbd5f7A4F73620),
address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780),
address(0x2775Fb7E8AC8A3AB06c9bf324c5F2c568D3768DF),
address(0x9930b69176E032Cb4F00AffA98b27cDe13D2411a),
address(0xE0A35b164F5c5e44E26d357E4Ac88e1b8714090f),
address(0x826976d7C600d45FB8287CA1d7c76FC8eb732030),
address(0xde51eD96afF11AD6894f8057B9A6D6Aa7D173a9c),
address(0x89FBe6875c932258B5541e2C1d3f64E597FB83C4),
address(0xC413436E1A6bC5942e0f5Af725c5eeA747b6c473),
address(0xf051aFc3bef06215A3b070F821DD60f93C216DD8),
address(0xf632Ce27Ea72deA30d30C1A9700B6b3bCeAA05cF),
address(0x4b8FA9979850a88fC5c197Dbc30918c697D54c1C),
address(0x4b8FA9979850a88fC5c197Dbc30918c697D54c1C),
address(0xb6bD440baBA4cB88F97BC25bc055ab7fBB6e9f8a),
address(0x5584A353528dfeB2Fc751Ab48b72D32726C79507),
address(0x02bE99141F66c065E165Caf2DbF6A987C8D107a5),
address(0x4AF474DAA96e2B6a64c52012b27966F2CF52b69e),
address(0x222e3cb8D92Bc316e9dc8b45eb218702bF94F9c1),
address(0x5136cDFC4D2b1A74774F5137095F82f88Af5ec99),
address(0xA2A2602bC84371E6A7af8b88467E8b3f10aa7658),
address(0xCd0D4CDb238Eec15Fcf4ff9d13d5a59051E507D7),
address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780),
address(0x7d547666209755FB833f9B37EebEa38eBF513Abb),
address(0x468Fd68b81475Ac46D00f491bFA52ef8AAa17e97),
address(0xf632Ce27Ea72deA30d30C1A9700B6b3bCeAA05cF),
address(0x7Ab13936BFFAC6C4981EE618d970d2b8F317bbf8),
address(0x8B5d712130A70D25bcE5A49f9cEf0000f6E12Ad9),
address(0xdA13146a15EFd3416Fe3D24FC30A8EC76E633B3f),
address(0xB08F0ca73E8A59a1b7970e22B8ed2F9142c3fA53),
address(0x443b29e221b54f7bE8C0805859f57028CFF0A1CA),
address(0x3B6918661577F2D44532c21cB97641808891fea0),
address(0x29131346d2f60595b27a3Dad68A0ae8f82b99aA4),
address(0x354Af718783c01a2592B1D479575A8fa14521cD9),
address(0x1263e7e4dE403357699eBB3e83455769d6F86BaE),
address(0x285b196Dfab5c9134cf9A7e8B74CFe9Abe34C3F7),
address(0x712054225Ac08595422b0BEe4c386Bd420F7e166),
address(0x468Fd68b81475Ac46D00f491bFA52ef8AAa17e97),
address(0x23077b24D9ffd4ef6b54D4279768F73db84790fE),
address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780),
address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780),
address(0xDD9cde0e6290B5F9160AF1844C8e607E7B25463e),
address(0xDd91C928d137112Cbca6D05d365cAef969b82ece),
address(0x33878e070db7f70D2953Fe0278Cd32aDf8104572),
address(0xE0A35b164F5c5e44E26d357E4Ac88e1b8714090f),
address(0x3fd0Ce9f00b690d8B6a6f7429652eb8743651402),
address(0x660F8e66D1183A54e85F586b61b9973Eb410A881),
address(0xc78C5564333BFC50172904CDF484952E0576cFD9),
address(0xf632Ce27Ea72deA30d30C1A9700B6b3bCeAA05cF),
address(0x4cB75146e98562C9d79b31649C6C739e4DCB7CD5),
address(0x844D6BdD58edDc41D2c81997AB32976E96094368),
address(0x091b95324525Ca0903D0923f4Fc213Df586491D0),
address(0x9B42eF5d4c0daEAA84E1fD5B73c847c0b172f1BE),
address(0x468Fd68b81475Ac46D00f491bFA52ef8AAa17e97),
address(0xb5ee030c71e76C3E03B2A8d425dBb9B395037C82),
address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780),
address(0x33878e070db7f70D2953Fe0278Cd32aDf8104572),
address(0xf632Ce27Ea72deA30d30C1A9700B6b3bCeAA05cF),
address(0x9477861457123C55cD34C608068c58af2BFF5DC8),
address(0xc28de09AD1a20737B92834943558DdfcC88d020D),
address(0x3FFD0C300fa4a021364Ae7e85a7b0d3a02133f99),
address(0x7688660055967dB4D0b68d4e0Cc3A43B2A5f044B),
address(0x8073639B11994C549eDa58fC3cd7132a72aaDF10),
address(0x5b655EDa7D101f98934392Cc3610BcB25b633789),
address(0xE04885c3f1419C6E8495C33bDCf5F8387cd88846),
address(0x5c7291e18c3ecF30E14CCf1DCD646c0CA3309113),
address(0x4A35674727c44cf4375d80C6171281Ba2f764213),
address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780),
address(0xd034Fd34eaEe5eC2c413C51936109E12873f4DA5),
address(0x5B1899D88b4Ff0Cf5A34651e7CE7164398211C66),
address(0xb03F5438f9A243De5C3B830B7841EC315034cD5f),
address(0x8dA48e5846c06B558970ACd42EDc7Da8799481E4),
address(0x685403A926846D4Fd11Ab93b75d5FFF5a7187190),
address(0xEd1131254Df36FD30B312aaCdB340Cd8B7a2D83A),
address(0x6199Dd389099276cA5aB25fF7e418498734AbF48),
address(0x008B0337aF3a082DAdE6d1f355dd03DE3981B666),
address(0x57F6Cbc6E783c16Ad5aA2350229bE35DDB42dCD1),
address(0x9E64099a479E637375362A24DE98C3233f377aD3),
address(0x54d77c6e986A2ae5C57DB0E22eE2E47E509237bC),
address(0xd9ffaF2e880dF0cc7B7104e9E789d281a81824cf),
address(0x685403A926846D4Fd11Ab93b75d5FFF5a7187190),
address(0xf31DF2dcD4083ee57f0d33d386656cfBD1E859a1),
address(0x94866bE528385546B658c85BdCC6f414a2Fb5Fd4),
address(0xBc1691780C0578e736323380A9C5FfD2ca578360),
address(0xC28064B875AE25f9a2CA28C08f116A5c26229f69),
address(0x00De4B13153673BCAE2616b67bf822500d325Fc3),
address(0x3fB0D1e89693b8709de60d835452a4712d1c9B04),
address(0x16ACcEFb4DD72f7892Ec2402fb1332b3861190E8),
address(0x839395e20bbB182fa440d08F850E6c7A8f6F0780),
address(0x7787476ada7Cd6e8c8aa715863F468d52856E09b),
address(0xd714Dd60e22BbB1cbAFD0e40dE5Cfa7bBDD3F3C8)

];

   

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 2000000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
    uint32 numWords = 2;

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    constructor()
        ConfirmedOwner(msg.sender)
        VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)
    {}

    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        getSample(_randomWords);

        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }

    function getSample(uint256[] memory randomWords) public  {

        // Random number between 0 and number of members - 1 for array indexing
        uint256 randStart = randomWords[0] % (members.length - 1);

        // Random number between 1 and number of members - 1 for incrementing
        uint256 randIncrement = randomWords[1] % (members.length - 2) + 1;

        // Random sample of member addresses
        sample = new address[](sampleSize);

        // Start with a random index 
        uint256 index = randStart;

        // Loop until the number of addressses in the sample array equals the sample size    
        for (uint256 i = 0; i < sampleSize; i++) {
            
            // Put the address of the member at the index in the sample array
            sample[i] = members[index];

            // Wrap the index if it exceeds the number of members
            if (index + randIncrement >= members.length) {
                index = (index + randIncrement) % members.length;
            
            // Add the random increment to the index
            } else {
                index += randIncrement;
            }        
        }
    }   


    function getRequestStatus(
        uint256 _requestId
    )
        external
        view
        returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
