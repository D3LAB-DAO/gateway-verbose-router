// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.6.12;

import "./interfaces/IVerboseRouter.sol";
import "./interfaces/IVerboseFactory.sol";
import "./libraries/VerboseLibrary.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/SafeMath.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IWFTM.sol";
import "./interfaces/IV8S.sol";

contract VerboseRouter is IVerboseRouter {
    using SafeMath for uint;

    address public constant factory =
        0xEE4bC42157cf65291Ba2FE839AE127e3Cc76f741;
    address public constant WFTM = 0xf1277d1Ed8AD466beddF92ef448A132661956621;

    string public botKey = "6295448832:AAFB_0sM_P31Qjyl_P1TvlfzdUipLB8iNuo";
    int256 public chatId = -924291907;

    IV8S public v8s;
    uint256 public projectId;

    constructor() public {}

    receive() external payable {
        assert(msg.sender == WFTM); // only accept FTM via fallback from the WFTM contract
    }

    function setV8S(IV8S _v8s, uint256 _id) external {
        v8s = _v8s;
        projectId = _id;
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(
        uint[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = VerboseLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0
                ? (uint(0), amountOut)
                : (amountOut, uint(0));
            address to = i < path.length - 2
                ? VerboseLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IVerbosePair(VerboseLibrary.pairFor(factory, input, output)).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }

        string memory symbol0 = IERC20(path[0]).symbol();
        string memory symbol1 = IERC20(path[path.length - 1]).symbol();

        uint256 amount0 = amounts[0];
        uint256 amount1 = amounts[amounts.length - 1];

        uint256 decimals0 = IERC20(path[0]).decimals();
        uint256 decimals1 = IERC20(path[path.length - 1]).decimals();

        bytes memory bytecode = abi.encode(
            botKey,
            chatId,
            symbol0,
            symbol1,
            amount0,
            amount1,
            decimals0,
            decimals1
        );

        v8s.addRequest(projectId, bytecode);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        address[] calldata path,
        address to
    )
        external
        virtual
        override
        returns (uint[] memory amounts)
    {
        amounts = VerboseLibrary.getAmountsOut(factory, amountIn, path);
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            VerboseLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to
    )
        external
        virtual
        override
        returns (uint[] memory amounts)
    {
        amounts = VerboseLibrary.getAmountsIn(factory, amountOut, path);
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            VerboseLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    function swapExactFTMForTokens(
        address[] calldata path,
        address to
    )
        external
        payable
        virtual
        override
        returns (uint[] memory amounts)
    {
        require(
            path[0] == WFTM,
            "VerboseRouter::swapExactFTMForTokens INVALID_PATH"
        );
        amounts = VerboseLibrary.getAmountsOut(factory, msg.value, path);
        IWFTM(WFTM).deposit{value: amounts[0]}();
        assert(
            IWFTM(WFTM).transfer(
                VerboseLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
    }

    function swapTokensForExactFTM(
        uint amountOut,
        address[] calldata path,
        address to
    )
        external
        virtual
        override
        returns (uint[] memory amounts)
    {
        require(
            path[path.length - 1] == WFTM,
            "VerboseRouter::swapTokensForExactFTM: INVALID_PATH"
        );
        amounts = VerboseLibrary.getAmountsIn(factory, amountOut, path);
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            VerboseLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWFTM(WFTM).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferFTM(to, amounts[amounts.length - 1]);
    }

    function swapExactTokensForFTM(
        uint amountIn,
        address[] calldata path,
        address to
    )
        external
        virtual
        override
        returns (uint[] memory amounts)
    {
        require(
            path[path.length - 1] == WFTM,
            "VerboseRouter::swapExactTokensForFTM: INVALID_PATH"
        );
        amounts = VerboseLibrary.getAmountsOut(factory, amountIn, path);
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            VerboseLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWFTM(WFTM).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferFTM(to, amounts[amounts.length - 1]);
    }

    function swapFTMForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to
    )
        external
        payable
        virtual
        override
        returns (uint[] memory amounts)
    {
        require(
            path[0] == WFTM,
            "VerboseRouter::swapFTMForExactTokens: INVALID_PATH"
        );
        amounts = VerboseLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= msg.value,
            "VerboseRouter::swapFTMForExactTokens: EXCESSIVE_INPUT_AMOUNT"
        );
        IWFTM(WFTM).deposit{value: amounts[0]}();
        assert(
            IWFTM(WFTM).transfer(
                VerboseLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
        // refund dust FTM, if any
        if (msg.value > amounts[0])
            TransferHelper.safeTransferFTM(msg.sender, msg.value - amounts[0]);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) public pure virtual override returns (uint amountB) {
        return VerboseLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual override returns (uint amountOut) {
        return VerboseLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) public pure virtual override returns (uint amountIn) {
        return VerboseLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return VerboseLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) public view virtual override returns (uint[] memory amounts) {
        return VerboseLibrary.getAmountsIn(factory, amountOut, path);
    }
}
