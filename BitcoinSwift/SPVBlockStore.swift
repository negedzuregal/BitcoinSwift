//
//  SPVBlockStore.swift
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

import Foundation

public protocol SPVBlockStore {

  var head: BlockHeader? { get }
  func blockHeaderWithHash(hash: SHA256Hash) -> BlockHeader?
  func addBlockHeader(blockHeader: BlockHeader)
  func removeBlockHeader(blockHeader: BlockHeader)
}
