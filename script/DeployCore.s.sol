// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import "forge-std/StdJson.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "../src/lib/MinimalImplementation.sol";
import "../src/StakingAccountant.sol";
import "../src/ValidatorManager.sol";
import "../src/PauserRegistry.sol";
import "../src/StakingManager.sol";
import "../src/OracleManager.sol";
import "../src/KHYPE.sol";

contract DeployCore is Script {
    using stdJson for string;
    // Update L1Write address

    address constant L1WRITE = 0x3333333333333333333333333333333333333333;

    // Contract instances
    PauserRegistry public pauserRegistry;
    StakingManager public stakingManager;
    KHYPE public kHYPE;
    ValidatorManager public validatorManager;
    StakingAccountant public stakingAccountant;
    OracleManager public oracleManager;

    // Proxy instances
    TransparentUpgradeableProxy public pauserRegistryProxy;
    TransparentUpgradeableProxy public stakingManagerProxy;
    TransparentUpgradeableProxy public kHYPEProxy;
    TransparentUpgradeableProxy public validatorManagerProxy;
    TransparentUpgradeableProxy public stakingAccountantProxy;
    TransparentUpgradeableProxy public oracleManagerProxy;

    // Config content
    string public config;
    string public configPath;

    // Add this variable to store the minimal implementation
    MinimalImplementation public minimalImplementation;

    function run(string memory _configPath) external {
        // Store config path
        configPath = _configPath;

        // Load configuration
        config = vm.readFile(configPath);

        vm.startBroadcast();

        // Deploy proxies first
        _deployProxies();
        vm.stopBroadcast();

        // Wait a bit between deployments
        vm.sleep(2000);

        vm.startBroadcast();
        _initializePauserRegistry();
        vm.stopBroadcast();

        vm.sleep(2000);

        vm.startBroadcast();
        _initializeStakingManager();
        vm.stopBroadcast();

        vm.sleep(2000);

        vm.startBroadcast();
        _initializeKHYPE();
        vm.stopBroadcast();

        vm.sleep(2000);

        vm.startBroadcast();
        _initializeValidatorManager();
        vm.stopBroadcast();

        vm.sleep(2000);

        vm.startBroadcast();
        _initializeStakingAccountant();
        vm.stopBroadcast();

        vm.sleep(2000);

        vm.startBroadcast();
        _initializeOracleManager();
        vm.stopBroadcast();

        // Log deployments
        _logDeployments();
    }

    function _deployProxy(string memory configKey, address owner) private returns (TransparentUpgradeableProxy proxy) {
        // Deploy minimal implementation if not already deployed
        if (address(minimalImplementation) == address(0)) {
            minimalImplementation = new MinimalImplementation();
        }

        // Read base salt and shift value
        uint256 saltShift = config.readUint(".deployment.saltShift");

        // Create unique salt for each proxy by hashing configKey and shifting
        bytes32 salt = bytes32(uint256(keccak256(bytes(configKey))) + saltShift);

        proxy = new TransparentUpgradeableProxy{salt: salt}(
            address(minimalImplementation),
            owner,
            "" // empty initialization data
        );
        // Then write the address
        vm.writeJson(vm.toString(address(proxy)), configPath, string.concat(".deployed.", configKey));
    }

    function _deployProxies() private {
        address owner = config.readAddress(".roles.admin");

        pauserRegistryProxy = _deployProxy("pauserRegistryProxy", owner);
        stakingManagerProxy = _deployProxy("stakingManagerProxy", owner);
        kHYPEProxy = _deployProxy("kHYPEProxy", owner);
        validatorManagerProxy = _deployProxy("validatorManagerProxy", owner);
        stakingAccountantProxy = _deployProxy("stakingAccountantProxy", owner);
        oracleManagerProxy = _deployProxy("oracleManagerProxy", owner);
    }

    function _getProxyAdmin(address proxy) internal view returns (address admin) {
        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        admin = address(uint160(uint256(adminSlot)));
    }

    function _initializePauserRegistry() private {
        // Deploy implementation and cast proxy
        PauserRegistry implementation = new PauserRegistry();
        pauserRegistry = PauserRegistry(address(implementation));

        // Get admin using helper function
        address proxyAdmin = _getProxyAdmin(address(pauserRegistryProxy));

        // Create array of proxy addresses that can be paused
        address[] memory proxies = new address[](4);
        proxies[0] = address(stakingManagerProxy);
        proxies[1] = address(kHYPEProxy);
        proxies[2] = address(validatorManagerProxy);
        proxies[3] = address(oracleManagerProxy);

        // Initialize
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(pauserRegistryProxy)),
            address(implementation),
            abi.encodeWithSelector(
                PauserRegistry.initialize.selector,
                config.readAddress(".roles.admin"),
                config.readAddress(".roles.pauser"),
                config.readAddress(".roles.unpauser"),
                config.readAddress(".roles.pauseAll"),
                proxies
            )
        );
    }

    function _initializeStakingManager() private {
        // Deploy implementation and cast proxy
        StakingManager implementation = new StakingManager();
        stakingManager = StakingManager(payable(address(implementation)));

        // Get admin using helper function
        address proxyAdmin = _getProxyAdmin(address(stakingManagerProxy));

        // Initialize with all required parameters
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(stakingManagerProxy)),
            address(implementation),
            abi.encodeWithSelector(
                StakingManager.initialize.selector,
                config.readAddress(".roles.admin"),
                config.readAddress(".roles.operator"),
                config.readAddress(".roles.manager"),
                address(pauserRegistryProxy),
                address(kHYPEProxy),
                address(validatorManagerProxy),
                address(stakingAccountantProxy),
                config.readAddress(".roles.treasury"),
                config.readUint(".staking.minStakeAmount"),
                config.readUint(".staking.maxStakeAmount"),
                config.readUint(".staking.stakingLimit"),
                config.readUint(".staking.withdrawalDelay"),
                config.readUint(".staking.hypeTokenId")
            )
        );
    }

    function _initializeKHYPE() private {
        // Deploy implementation and cast proxy
        KHYPE implementation = new KHYPE();
        kHYPE = KHYPE(address(implementation));

        // Get admin using helper function
        address proxyAdmin = _getProxyAdmin(address(kHYPEProxy));

        // Initialize
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(kHYPEProxy)),
            address(implementation),
            abi.encodeWithSelector(
                KHYPE.initialize.selector,
                config.readString(".token.name"),
                config.readString(".token.symbol"),
                config.readAddress(".roles.admin"),
                address(stakingManagerProxy),
                address(stakingManagerProxy),
                address(pauserRegistryProxy)
            )
        );
    }

    function _initializeValidatorManager() private {
        // Deploy implementation and cast proxy
        ValidatorManager implementation = new ValidatorManager();
        validatorManager = ValidatorManager(address(implementation));

        // Get admin using helper function
        address proxyAdmin = _getProxyAdmin(address(validatorManagerProxy));

        // Initialize
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(validatorManagerProxy)),
            address(implementation),
            abi.encodeWithSelector(
                ValidatorManager.initialize.selector,
                config.readAddress(".roles.admin"),
                config.readAddress(".roles.validatorManager"),
                address(oracleManagerProxy),
                address(pauserRegistryProxy)
            )
        );
    }

    function _initializeStakingAccountant() private {
        // Deploy implementation and cast proxy
        StakingAccountant implementation = new StakingAccountant();
        stakingAccountant = StakingAccountant(address(implementation));

        // Get admin using helper function
        address proxyAdmin = _getProxyAdmin(address(stakingAccountantProxy));

        // Initialize
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(stakingAccountantProxy)),
            address(implementation),
            abi.encodeWithSelector(
                StakingAccountant.initialize.selector,
                config.readAddress(".roles.admin"),
                config.readAddress(".roles.manager"),
                address(validatorManagerProxy),
                address(kHYPEProxy)
            )
        );
        StakingAccountant(address(stakingAccountantProxy)).authorizeStakingManager(
            address(stakingManagerProxy),
            address(kHYPEProxy)
        );
    }

    function _initializeOracleManager() private {
        // Deploy implementation and cast proxy
        OracleManager implementation = new OracleManager();
        oracleManager = OracleManager(address(implementation));

        // Get admin using helper function
        address proxyAdmin = _getProxyAdmin(address(oracleManagerProxy));

        // Initialize
        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(oracleManagerProxy)),
            address(implementation),
            abi.encodeWithSelector(
                OracleManager.initialize.selector,
                config.readAddress(".roles.admin"),
                config.readAddress(".roles.oracleOperator"),
                config.readAddress(".roles.oracleManager"),
                address(pauserRegistryProxy),
                address(validatorManagerProxy),
                config.readUint(".oracle.maxPerformanceBound")
            )
        );
    }

    function _logDeployments() private view {
        console.log("\n=== Proxies ===");
        console.log("PauserRegistry Proxy:", address(pauserRegistryProxy));
        console.log("StakingManager Proxy:", address(stakingManagerProxy));
        console.log("KHYPE Proxy:", address(kHYPEProxy));
        console.log("ValidatorManager Proxy:", address(validatorManagerProxy));
        console.log("StakingAccountant Proxy:", address(stakingAccountantProxy));
        console.log("OracleManager Proxy:", address(oracleManagerProxy));

        console.log("\n=== Implementations ===");
        console.log("PauserRegistry Impl:", address(pauserRegistry));
        console.log("StakingManager Impl:", address(stakingManager));
        console.log("KHYPE Impl:", address(kHYPE));
        console.log("ValidatorManager Impl:", address(validatorManager));
        console.log("StakingAccountant Impl:", address(stakingAccountant));
        console.log("OracleManager Impl:", address(oracleManager));

        console.log("\n=== Roles ===");
        console.log("Admin:", config.readAddress(".roles.admin"));
        console.log("Pauser:", config.readAddress(".roles.pauser"));
        console.log("Unpauser:", config.readAddress(".roles.unpauser"));
        console.log("Validator Manager:", config.readAddress(".roles.validatorManager"));
        console.log("Validator Sentinel:", config.readAddress(".roles.validatorSentinel"));
        console.log("Oracle Manager:", config.readAddress(".roles.oracleManager"));
        console.log("Oracle Operator:", config.readAddress(".roles.oracleOperator"));

        console.log("\n=== Staking Configuration ===");
        console.log("Min Stake:", config.readUint(".staking.minStakeAmount"), "wei");
        console.log("Max Stake:", config.readUint(".staking.maxStakeAmount"), "wei");
        console.log("Staking Limit:", config.readUint(".staking.stakingLimit"), "wei");

        console.log("\n=== Oracle Configuration ===");
        console.log("Max Performance Bound:", config.readUint(".oracle.maxPerformanceBound"), "BP");

        console.log("\n=== System Addresses ===");
        console.log("L1Write:", config.readAddress(".addresses.l1Write"));
    }
}
