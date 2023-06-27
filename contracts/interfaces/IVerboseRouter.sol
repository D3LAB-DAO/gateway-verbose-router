// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IVerboseRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        address[] calldata path,
        address to
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to
    ) external returns (uint[] memory amounts);

    function swapExactFTMForTokens(
        address[] calldata path,
        address to
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactFTM(
        uint amountOut,
        address[] calldata path,
        address to
    ) external returns (uint[] memory amounts);

    function swapExactTokensForFTM(
        uint amountIn,
        address[] calldata path,
        address to
    ) external returns (uint[] memory amounts);

    function swapFTMForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}
