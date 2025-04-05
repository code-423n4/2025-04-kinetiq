// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {MinimalImplementation} from "../src/lib/MinimalImplementation.sol";
import {StakingAccountant} from "../src/StakingAccountant.sol";
import {ValidatorManager} from "../src/ValidatorManager.sol";
import {PauserRegistry} from "../src/PauserRegistry.sol";
import {StakingManager} from "../src/StakingManager.sol";
import {OracleManager} from "../src/OracleManager.sol";
import {L1Write} from "../src/lib/L1Write.sol";
import {KHYPE} from "../src/KHYPE.sol";
import "forge-std/console.sol";

contract BaseTest is Test {
    // Contract instances
    PauserRegistry public pauserRegistry;
    StakingManager public stakingManager;
    KHYPE public kHYPE;
    ValidatorManager public validatorManager;
    OracleManager public oracleManager;
    StakingAccountant public stakingAccountant;

    // Update L1Write address
    address constant L1WRITE = 0x3333333333333333333333333333333333333333;

    // Common addresses using Forge's makeAddr
    address public admin = makeAddr("admin");
    address public manager = makeAddr("manager");
    address public sentinel = makeAddr("sentinel");
    address public operator = makeAddr("operator");

    address public pauser = makeAddr("pauser");
    address public unpauser = makeAddr("unpauser");
    address public pauseAll = makeAddr("pauseAll");
    address public user = makeAddr("user");

    // Add treasury address
    address public treasury = makeAddr("treasury");

    // Deployment parameters
    uint256 public minStake = 0.1 ether;
    uint256 public maxStake = 1 ether;
    uint256 public stakingLimit = 10_000 ether;
    uint256 public minProcessing = 1 ether;
    uint256 public maxProcessing = 100 ether;
    uint256 public rebalanceThreshold = 500; // 5%
    uint256 public defaultWeightage = 10_000;
    uint256 public maxPerformanceBound = 10_000;

    function _getProxyAdmin(address proxy) internal view returns (address) {
        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        return address(uint160(uint256(adminSlot)));
    }

    function setUp() public virtual {
        console.log("Starting setUp");

        // Deploy L1Write at specific address
        L1Write l1WriteImpl = new L1Write();
        vm.etch(L1WRITE, address(l1WriteImpl).code);

        // Deploy minimal implementation for proxies
        MinimalImplementation minimalImpl = new MinimalImplementation();
        console.log("Minimal implementation deployed at:", address(minimalImpl));

        // Deploy proxies - each will create its own ProxyAdmin
        console.log("Deploying proxies...");
        TransparentUpgradeableProxy pauserRegistryProxy = new TransparentUpgradeableProxy(
            address(minimalImpl),
            admin,
            ""
        );
        console.log("PauserRegistry proxy deployed at:", address(pauserRegistryProxy));
        address pauserRegistryAdmin = _getProxyAdmin(address(pauserRegistryProxy));
        console.log("PauserRegistry admin at:", pauserRegistryAdmin);

        TransparentUpgradeableProxy stakingManagerProxy = new TransparentUpgradeableProxy(
            address(minimalImpl),
            admin,
            ""
        );
        console.log("StakingManager proxy deployed at:", address(stakingManagerProxy));
        address stakingManagerAdmin = _getProxyAdmin(address(stakingManagerProxy));
        console.log("StakingManager admin at:", stakingManagerAdmin);

        TransparentUpgradeableProxy kHYPEProxy = new TransparentUpgradeableProxy(address(minimalImpl), admin, "");
        console.log("KHYPE proxy deployed at:", address(kHYPEProxy));
        address kHYPEAdmin = _getProxyAdmin(address(kHYPEProxy));
        console.log("KHYPE admin at:", kHYPEAdmin);

        TransparentUpgradeableProxy validatorManagerProxy = new TransparentUpgradeableProxy(
            address(minimalImpl),
            admin,
            ""
        );
        console.log("ValidatorManager proxy deployed at:", address(validatorManagerProxy));
        address validatorManagerAdmin = _getProxyAdmin(address(validatorManagerProxy));
        console.log("ValidatorManager admin at:", validatorManagerAdmin);

        TransparentUpgradeableProxy oracleManagerProxy = new TransparentUpgradeableProxy(
            address(minimalImpl),
            admin,
            ""
        );
        console.log("OracleManager proxy deployed at:", address(oracleManagerProxy));
        address oracleManagerAdmin = _getProxyAdmin(address(oracleManagerProxy));
        console.log("OracleManager admin at:", oracleManagerAdmin);

        TransparentUpgradeableProxy stakingAccountantProxy = new TransparentUpgradeableProxy(
            address(minimalImpl),
            admin,
            ""
        );
        console.log("StakingAccountant proxy deployed at:", address(stakingAccountantProxy));
        address stakingAccountantAdmin = _getProxyAdmin(address(stakingAccountantProxy));
        console.log("StakingAccountant admin at:", stakingAccountantAdmin);

        // Cast proxies
        pauserRegistry = PauserRegistry(address(pauserRegistryProxy));
        stakingManager = StakingManager(payable(address(stakingManagerProxy)));
        kHYPE = KHYPE(address(kHYPEProxy));
        validatorManager = ValidatorManager(address(validatorManagerProxy));
        oracleManager = OracleManager(address(oracleManagerProxy));
        stakingAccountant = StakingAccountant(address(stakingAccountantProxy));

        vm.startPrank(admin);
        console.log("Started admin prank");

        // Create array of pausable contracts
        console.log("Creating pausable contracts array");
        address[] memory pausableContracts = new address[](4);
        pausableContracts[0] = address(stakingManager);
        pausableContracts[1] = address(kHYPE);
        pausableContracts[2] = address(validatorManager);
        pausableContracts[3] = address(oracleManager);

        // Initialize PauserRegistry
        ProxyAdmin(pauserRegistryAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(pauserRegistry)),
            address(new PauserRegistry()),
            abi.encodeWithSelector(
                PauserRegistry.initialize.selector,
                admin,
                pauser,
                unpauser,
                pauseAll,
                pausableContracts
            )
        );

        // Initialize KHYPE
        ProxyAdmin(kHYPEAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(kHYPE)),
            address(new KHYPE()),
            abi.encodeWithSelector(
                KHYPE.initialize.selector,
                "kHYPE Token",
                "KHYPE",
                admin,
                address(stakingManager),
                address(stakingManager),
                address(pauserRegistry)
            )
        );

        // Initialize ValidatorManager
        ProxyAdmin(validatorManagerAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(validatorManager)),
            address(new ValidatorManager()),
            abi.encodeWithSelector(
                ValidatorManager.initialize.selector,
                admin, // DEFAULT_ADMIN_ROLE
                manager, // MANAGER_ROLE
                address(oracleManager), // ORACLE_ROLE
                address(pauserRegistry)
            )
        );

        // Initialize StakingAccountant
        ProxyAdmin(stakingAccountantAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(stakingAccountant)),
            address(new StakingAccountant()),
            abi.encodeWithSelector(
                StakingAccountant.initialize.selector,
                admin,
                manager,
                address(validatorManager),
                address(kHYPE)
            )
        );

        // Initialize StakingManager with StakingAccountant
        ProxyAdmin(stakingManagerAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(stakingManager)),
            address(new StakingManager()),
            abi.encodeWithSelector(
                StakingManager.initialize.selector,
                admin, // DEFAULT_ADMIN_ROLE
                operator, // OPERATOR_ROLE
                manager, // MANAGER_ROLE
                address(pauserRegistry),
                address(kHYPE),
                address(validatorManager),
                address(stakingAccountant),
                treasury,
                minStake,
                maxStake,
                stakingLimit,
                0,
                1105
            )
        );

        // Initialize OracleManager
        ProxyAdmin(oracleManagerAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(address(oracleManager)),
            address(new OracleManager()),
            abi.encodeWithSelector(
                OracleManager.initialize.selector,
                admin, // DEFAULT_ADMIN_ROLE
                operator, // OPERATOR_ROLE
                manager, // MANAGER_ROLE
                address(pauserRegistry),
                address(validatorManager),
                maxPerformanceBound
            )
        );
        vm.stopPrank();

        // Setup roles
        vm.startPrank(manager);
        stakingAccountant.authorizeStakingManager(address(stakingManager), address(kHYPE));
        vm.stopPrank();

        console.log("Setup completed");
    }
}
