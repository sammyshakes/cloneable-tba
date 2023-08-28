// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC721CloneableTBA {
    function mint(address to, uint256 tokenId) external returns (address payable);
}

interface IERC1155Cloneable {
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;
}

contract TronicAdmin {
    struct PartnerInfo {
        address erc721Address;
        address erc1155Address;
        string partnerName;
    }

    enum TokenType {
        ERC1155,
        ERC721
    }

    // Mapping to store addresses of all partners' ERC-721 and ERC-1155 contracts using a generated ID
    mapping(uint256 => PartnerInfo) public partners;

    // Counter to generate unique IDs for partners
    uint256 public partnerCounter = 0;

    // The address of the Tronic owner/admin
    address public owner;

    // Modifiers for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Constructor to set the initial owner/admin of Tronic
    constructor() {
        owner = msg.sender;
    }

    function getPartnerInfo(uint256 partnerId) external view returns (PartnerInfo memory) {
        return partners[partnerId];
    }

    // Function to add a new partner's ERC-721 and ERC-1155 contract addresses
    function addPartnerContracts(
        string memory _partnerName,
        address _erc721Address,
        address _erc1155Address
    ) external onlyOwner {
        partners[partnerCounter] = PartnerInfo({
            erc721Address: _erc721Address,
            erc1155Address: _erc1155Address,
            partnerName: _partnerName
        });
        partnerCounter++;
    }

    // Function to remove a partner's contracts (considering the challenges of removing from a mapping)
    function removePartner(uint256 _partnerId) external onlyOwner {
        delete partners[_partnerId];
    }

    /// @notice Processes multiple minting operations for both ERC1155 and ERC721 tokens on behalf of partners.
    /// @param _partnerIds   Array of partner IDs corresponding to each minting operation.
    /// @param _tokenIds     2D array of token IDs to mint for each partner.
    ///                      For ERC1155, it could be multiple IDs, and for ERC721, it should contain a single ID.
    /// @param _amounts      2D array of token amounts to mint for each partner.
    ///                      For ERC1155, it represents the quantities of each token ID, and for ERC721, it should be either [1] (to mint) or [0] (to skip).
    /// @param _recipients   Array of recipient addresses for each minting operation.
    /// @param _tokenTypes   Array specifying the type of each token (either ERC1155 or ERC721) to determine the minting logic.
    /// @dev Requires that all input arrays have matching lengths.
    ///      For ERC721 minting, the inner arrays of _tokenIds and _amounts should have a length of 1.
    function batchProcess(
        uint256[] memory _partnerIds,
        uint256[][] memory _tokenIds,
        uint256[][] memory _amounts,
        address[] memory _recipients,
        TokenType[] memory _tokenTypes
    ) external onlyOwner {
        require(
            _partnerIds.length == _tokenIds.length && _tokenIds.length == _amounts.length
                && _amounts.length == _recipients.length && _recipients.length == _tokenTypes.length,
            "Arrays must have the same length"
        );

        for (uint256 i = 0; i < _partnerIds.length; i++) {
            PartnerInfo memory partner = partners[_partnerIds[i]];

            if (_tokenTypes[i] == TokenType.ERC1155) {
                // Check if the tokenIds and amounts for this partner have the same length
                require(
                    _tokenIds[i].length == _amounts[i].length,
                    "TokenIds and amounts arrays for a partner must have the same length"
                );

                // Using the IERC1155Cloneable interface, call the mintBatch function
                IERC1155Cloneable(partner.erc1155Address).mintBatch(
                    _recipients[i], _tokenIds[i], _amounts[i], ""
                );
            } else if (_tokenTypes[i] == TokenType.ERC721) {
                require(_tokenIds[i].length == 1, "ERC721 should have a single tokenId for minting");
                require(_amounts[i][0] == 1, "ERC721 minting amount should be 1");

                // Using the IERC721 interface, call the mint function
                // Assuming your ERC721 implementation has a mint function with this signature
                IERC721CloneableTBA(partner.erc721Address).mint(_recipients[i], _tokenIds[i][0]);
            }
        }
    }
}
