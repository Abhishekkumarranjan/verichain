// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VeriChain - Supply Chain Verification System
 * @dev A smart contract for tracking and verifying products through supply chain
 */
contract VeriChain {
    
    // Product structure to store product information
    struct Product {
        uint256 id;
        string name;
        string manufacturer;
        uint256 manufacturingDate;
        string currentLocation;
        address currentOwner;
        bool isVerified;
        string[] checkpoints;
    }
    
    // Events for tracking product lifecycle
    event ProductCreated(uint256 indexed productId, string name, string manufacturer);
    event ProductTransferred(uint256 indexed productId, address indexed from, address indexed to, string location);
    event ProductVerified(uint256 indexed productId, address indexed verifier);
    
    // State variables
    mapping(uint256 => Product) public products;
    mapping(address => bool) public authorizedManufacturers;
    mapping(address => bool) public authorizedVerifiers;
    uint256 public productCounter;
    address public owner;
    
    // Modifiers for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }
    
    modifier onlyManufacturer() {
        require(authorizedManufacturers[msg.sender], "Only authorized manufacturers can perform this action");
        _;
    }
    
    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender], "Only authorized verifiers can perform this action");
        _;
    }
    
    modifier productExists(uint256 _productId) {
        require(_productId > 0 && _productId <= productCounter, "Product does not exist");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        productCounter = 0;
        // Contract deployer is automatically an authorized manufacturer and verifier
        authorizedManufacturers[msg.sender] = true;
        authorizedVerifiers[msg.sender] = true;
    }
    
    /**
     * @dev Core Function 1: Create a new product in the supply chain
     * @param _name Product name
     * @param _manufacturer Manufacturer name
     * @param _initialLocation Initial location of the product
     */
    function createProduct(
        string memory _name,
        string memory _manufacturer,
        string memory _initialLocation
    ) external onlyManufacturer returns (uint256) {
        require(bytes(_name).length > 0, "Product name cannot be empty");
        require(bytes(_manufacturer).length > 0, "Manufacturer name cannot be empty");
        
        productCounter++;
        
        Product storage newProduct = products[productCounter];
        newProduct.id = productCounter;
        newProduct.name = _name;
        newProduct.manufacturer = _manufacturer;
        newProduct.manufacturingDate = block.timestamp;
        newProduct.currentLocation = _initialLocation;
        newProduct.currentOwner = msg.sender;
        newProduct.isVerified = false;
        newProduct.checkpoints.push(string(abi.encodePacked("Created at ", _initialLocation, " on ", uint2str(block.timestamp))));
        
        emit ProductCreated(productCounter, _name, _manufacturer);
        
        return productCounter;
    }
    
    /**
     * @dev Core Function 2: Transfer product ownership and update location
     * @param _productId Product ID to transfer
     * @param _newOwner New owner address
     * @param _newLocation New location of the product
     */
    function transferProduct(
        uint256 _productId,
        address _newOwner,
        string memory _newLocation
    ) external productExists(_productId) {
        require(_newOwner != address(0), "Invalid new owner address");
        require(products[_productId].currentOwner == msg.sender, "Only current owner can transfer product");
        require(bytes(_newLocation).length > 0, "Location cannot be empty");
        
        address previousOwner = products[_productId].currentOwner;
        
        products[_productId].currentOwner = _newOwner;
        products[_productId].currentLocation = _newLocation;
        products[_productId].checkpoints.push(string(abi.encodePacked("Transferred to ", _newLocation, " on ", uint2str(block.timestamp))));
        
        emit ProductTransferred(_productId, previousOwner, _newOwner, _newLocation);
    }
    
    /**
     * @dev Core Function 3: Verify product authenticity
     * @param _productId Product ID to verify
     */
    function verifyProduct(uint256 _productId) external onlyVerifier productExists(_productId) {
        require(!products[_productId].isVerified, "Product is already verified");
        
        products[_productId].isVerified = true;
        products[_productId].checkpoints.push(string(abi.encodePacked("Verified on ", uint2str(block.timestamp))));
        
        emit ProductVerified(_productId, msg.sender);
    }
    
    // Additional utility functions
    
    /**
     * @dev Get complete product information
     * @param _productId Product ID to query
     */
    function getProduct(uint256 _productId) external view productExists(_productId) returns (
        uint256 id,
        string memory name,
        string memory manufacturer,
        uint256 manufacturingDate,
        string memory currentLocation,
        address currentOwner,
        bool isVerified,
        string[] memory checkpoints
    ) {
        Product storage product = products[_productId];
        return (
            product.id,
            product.name,
            product.manufacturer,
            product.manufacturingDate,
            product.currentLocation,
            product.currentOwner,
            product.isVerified,
            product.checkpoints
        );
    }
    
    /**
     * @dev Add authorized manufacturer
     */
    function addManufacturer(address _manufacturer) external onlyOwner {
        require(_manufacturer != address(0), "Invalid manufacturer address");
        authorizedManufacturers[_manufacturer] = true;
    }
    
    /**
     * @dev Add authorized verifier
     */
    function addVerifier(address _verifier) external onlyOwner {
        require(_verifier != address(0), "Invalid verifier address");
        authorizedVerifiers[_verifier] = true;
    }
    
    /**
     * @dev Remove authorized manufacturer
     */
    function removeManufacturer(address _manufacturer) external onlyOwner {
        authorizedManufacturers[_manufacturer] = false;
    }
    
    /**
     * @dev Remove authorized verifier
     */
    function removeVerifier(address _verifier) external onlyOwner {
        authorizedVerifiers[_verifier] = false;
    }
    
    /**
     * @dev Get total number of products created
     */
    function getTotalProducts() external view returns (uint256) {
        return productCounter;
    }
    
    /**
     * @dev Utility function to convert uint to string
     */
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b = bytes1(temp);
            bstr[k] = b;
            _i /= 10;
        }
        return string(bstr);
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VeriChain - Supply Chain Verification System
 * @dev A smart contract for tracking and verifying products through supply chain
 */
contract VeriChain {
    
    // Product structure to store product information
    struct Product {
        uint256 id;
        string name;
        string manufacturer;
        uint256 manufacturingDate;
        string currentLocation;
        address currentOwner;
        bool isVerified;
        string[] checkpoints;
    }
    
    // Events for tracking product lifecycle
    event ProductCreated(uint256 indexed productId, string name, string manufacturer);
    event ProductTransferred(uint256 indexed productId, address indexed from, address indexed to, string location);
    event ProductVerified(uint256 indexed productId, address indexed verifier);
    
    // State variables
    mapping(uint256 => Product) public products;
    mapping(address => bool) public authorizedManufacturers;
    mapping(address => bool) public authorizedVerifiers;
    uint256 public productCounter;
    address public owner;
    
    // Modifiers for access control
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }
    
    modifier onlyManufacturer() {
        require(authorizedManufacturers[msg.sender], "Only authorized manufacturers can perform this action");
        _;
    }
    
    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender], "Only authorized verifiers can perform this action");
        _;
    }
    
    modifier productExists(uint256 _productId) {
        require(_productId > 0 && _productId <= productCounter, "Product does not exist");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        productCounter = 0;
        // Contract deployer is automatically an authorized manufacturer and verifier
        authorizedManufacturers[msg.sender] = true;
        authorizedVerifiers[msg.sender] = true;
    }
    
    /**
     * @dev Core Function 1: Create a new product in the supply chain
     * @param _name Product name
     * @param _manufacturer Manufacturer name
     * @param _initialLocation Initial location of the product
     */
    function createProduct(
        string memory _name,
        string memory _manufacturer,
        string memory _initialLocation
    ) external onlyManufacturer returns (uint256) {
        require(bytes(_name).length > 0, "Product name cannot be empty");
        require(bytes(_manufacturer).length > 0, "Manufacturer name cannot be empty");
        
        productCounter++;
        
        Product storage newProduct = products[productCounter];
        newProduct.id = productCounter;
        newProduct.name = _name;
        newProduct.manufacturer = _manufacturer;
        newProduct.manufacturingDate = block.timestamp;
        newProduct.currentLocation = _initialLocation;
        newProduct.currentOwner = msg.sender;
        newProduct.isVerified = false;
        newProduct.checkpoints.push(string(abi.encodePacked("Created at ", _initialLocation, " on ", uint2str(block.timestamp))));
        
        emit ProductCreated(productCounter, _name, _manufacturer);
        
        return productCounter;
    }
    
    /**
     * @dev Core Function 2: Transfer product ownership and update location
     * @param _productId Product ID to transfer
     * @param _newOwner New owner address
     * @param _newLocation New location of the product
     */
    function transferProduct(
        uint256 _productId,
        address _newOwner,
        string memory _newLocation
    ) external productExists(_productId) {
        require(_newOwner != address(0), "Invalid new owner address");
        require(products[_productId].currentOwner == msg.sender, "Only current owner can transfer product");
        require(bytes(_newLocation).length > 0, "Location cannot be empty");
        
        address previousOwner = products[_productId].currentOwner;
        
        products[_productId].currentOwner = _newOwner;
        products[_productId].currentLocation = _newLocation;
        products[_productId].checkpoints.push(string(abi.encodePacked("Transferred to ", _newLocation, " on ", uint2str(block.timestamp))));
        
        emit ProductTransferred(_productId, previousOwner, _newOwner, _newLocation);
    }
    
    /**
     * @dev Core Function 3: Verify product authenticity
     * @param _productId Product ID to verify
     */
    function verifyProduct(uint256 _productId) external onlyVerifier productExists(_productId) {
        require(!products[_productId].isVerified, "Product is already verified");
        
        products[_productId].isVerified = true;
        products[_productId].checkpoints.push(string(abi.encodePacked("Verified on ", uint2str(block.timestamp))));
        
        emit ProductVerified(_productId, msg.sender);
    }
    
    // Additional utility functions
    
    /**
     * @dev Get complete product information
     * @param _productId Product ID to query
     */
    function getProduct(uint256 _productId) external view productExists(_productId) returns (
        uint256 id,
        string memory name,
        string memory manufacturer,
        uint256 manufacturingDate,
        string memory currentLocation,
        address currentOwner,
        bool isVerified,
        string[] memory checkpoints
    ) {
        Product storage product = products[_productId];
        return (
            product.id,
            product.name,
            product.manufacturer,
            product.manufacturingDate,
            product.currentLocation,
            product.currentOwner,
            product.isVerified,
            product.checkpoints
        );
    }
    
    /**
     * @dev Add authorized manufacturer
     */
    function addManufacturer(address _manufacturer) external onlyOwner {
        require(_manufacturer != address(0), "Invalid manufacturer address");
        authorizedManufacturers[_manufacturer] = true;
    }
    
    /**
     * @dev Add authorized verifier
     */
    function addVerifier(address _verifier) external onlyOwner {
        require(_verifier != address(0), "Invalid verifier address");
        authorizedVerifiers[_verifier] = true;
    }
    
    /**
     * @dev Remove authorized manufacturer
     */
    function removeManufacturer(address _manufacturer) external onlyOwner {
        authorizedManufacturers[_manufacturer] = false;
    }
    
    /**
     * @dev Remove authorized verifier
     */
    function removeVerifier(address _verifier) external onlyOwner {
        authorizedVerifiers[_verifier] = false;
    }
    
    /**
     * @dev Get total number of products created
     */
    function getTotalProducts() external view returns (uint256) {
        return productCounter;
    }
    
    /**
     * @dev Utility function to convert uint to string
     */
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b = bytes1(temp);
            bstr[k] = b;
            _i /= 10;
        }
        return string(bstr);
    }
}
