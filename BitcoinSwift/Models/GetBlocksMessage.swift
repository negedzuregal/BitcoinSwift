//
//  GetBlocksMessage.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 9/27/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public func ==(left: GetBlocksMessage, right: GetBlocksMessage) -> Bool {
  return left.protocolVersion == right.protocolVersion &&
      left.blockLocatorHashes == right.blockLocatorHashes &&
      left.blockHashStop == right.blockHashStop
}

/// Message payload object corresponding to the Message.Command.GetBlocks command. Return an inv
/// packet containing the list of blocks starting right after the last known hash in the block
/// locator object, up to blockHashStop or 500 blocks, whichever comes first.
/// https://en.bitcoin.it/wiki/Protocol_specification#getblocks
public struct GetBlocksMessage: Equatable {

  public let protocolVersion: UInt32
  public let blockLocatorHashes: [NSData]
  public let blockHashStop: NSData?

  public init(protocolVersion: UInt32, blockLocatorHashes: [NSData], blockHashStop: NSData? = nil) {
    precondition(blockLocatorHashes.count > 0, "Must include at least one blockHash")
    self.protocolVersion = protocolVersion
    self.blockLocatorHashes = blockLocatorHashes
    self.blockHashStop = blockHashStop
  }
}

extension GetBlocksMessage: MessagePayload {

  public var command: Message.Command {
    return Message.Command.GetBlocks
  }

  public var bitcoinData: NSData {
    var data = NSMutableData()
    data.appendUInt32(protocolVersion)
    data.appendVarInt(blockLocatorHashes.count)
    for blockLocatorHash in blockLocatorHashes {
      data.appendData(blockLocatorHash)
    }
    if let hashStop = blockHashStop {
      data.appendData(hashStop)
    } else {
      data.appendData(NSMutableData(length: 32)!)
    }
    return data
  }

  public static func fromBitcoinStream(stream: NSInputStream) -> GetBlocksMessage? {
    let protocolVersion = stream.readUInt32()
    if protocolVersion == nil {
      Logger.warn("Failed to parse protocolVersion from GetBlocksMessage")
      return nil
    }
    let hashCount = stream.readVarInt()
    if hashCount == nil {
      Logger.warn("Failed to parse hashCount from GetBlocksMessage")
      return nil
    }
    var blockLocatorHashes: [NSData] = []
    for _ in 0..<hashCount! {
      let blockLocatorHash = stream.readData(length: 32)
      if blockLocatorHash == nil {
        Logger.warn("Failed to parse blockLocatorHash from GetBlocksMessage")
        return nil
      }
      blockLocatorHashes.append(blockLocatorHash!)
    }
    var blockHashStop = stream.readData(length: 32)
    if blockHashStop == nil {
      Logger.warn("Failed to parse blockHashStop from GetBlocksMessage")
      return nil
    }
    let zeroHash = NSMutableData(length: 32)
    if blockHashStop == zeroHash {
      // blockHashStop will be 0 to get as many blocks as possible (max 500 blocks).
      blockHashStop = nil
    }
    return GetBlocksMessage(protocolVersion: protocolVersion!,
                            blockLocatorHashes: blockLocatorHashes,
                            blockHashStop: blockHashStop)
  }
}
