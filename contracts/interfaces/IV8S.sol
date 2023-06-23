// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.6.12;

interface IV8S {
    struct Project {
        string url;
    }

    struct Request {
        bytes data;
        uint projectId;
        bool hasResponse;
    }

    struct Response {
        bytes responseData;
        uint requestId;
    }

    function projects(uint projectId) external view returns (string memory);
    function addProject(string memory url) external returns (uint);
    function addRequest(uint projectId, bytes memory data) external returns (uint);
    function addResponse(uint requestId, bytes memory responseData) external returns (uint);
    function getRequest(uint requestId) external view returns (bytes memory, uint);
    function getResponse(uint requestId) external view returns (bytes memory, uint);
    function isResponseExists(uint requestId) external view returns (bool);
    function getUnrespondedRequests() external view returns (uint[] memory);
}
