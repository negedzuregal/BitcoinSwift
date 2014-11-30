//
//  BigInteger.m
//  BitcoinSwift
//
//  Created by Kevin Greene on 11/29/14.
//  Copyright (c) 2014 DoubleSha. All rights reserved.
//

#import "BigInteger.h"

#import <openssl/bn.h>

@interface BigInteger()

@property(nonatomic, assign) BIGNUM *bn;

@end

@implementation BigInteger

- (instancetype)init {
  return [self initWithData:nil];
}

- (instancetype)init:(int)value {
  return [self initWithIntegerLiteral:value];
}

- (instancetype)initWithIntegerLiteral:(int)value {
  self = [super init];
  if (self) {
    _bn = BN_new();
    BN_set_word(_bn, value);
  }
  return self;
}

- (instancetype)initWithData:(NSData *)data {
  self = [super init];
  if (self) {
    _bn = BN_new();
    if (data) {
      BN_bin2bn([data bytes], (int)[data length], _bn);
    }
  }
  return self;
}

- (void)dealloc {
  BN_free(_bn);
}

- (NSData *)data {
  int numBytes = BN_num_bytes(_bn);
  if (numBytes == 0) {
    return [[NSData alloc] init];
  }
  unsigned char buffer[numBytes];
  BN_bn2bin(_bn, buffer);
  return [NSData dataWithBytes:buffer length:numBytes];
}

- (BigInteger *)add:(BigInteger *)other {
  BigInteger *result = [[BigInteger alloc] init];
  BN_add(result.bn, _bn, other.bn);
  return result;
}

- (BigInteger *)subtract:(BigInteger *)other {
  BigInteger *result = [[BigInteger alloc] init];
  BN_sub(result.bn, _bn, other.bn);
  return result;
}

- (BigInteger *)multiply:(BigInteger *)other {
  BN_CTX *ctx = BN_CTX_new();
  BigInteger *result = [[BigInteger alloc] init];
  BN_mul(result.bn, _bn, other.bn, ctx);
  BN_CTX_free(ctx);
  return result;
}

- (BigInteger *)divide:(BigInteger *)other {
  BN_CTX *ctx = BN_CTX_new();
  BigInteger *result = [[BigInteger alloc] init];
  BN_div(result.bn, NULL, _bn, other.bn, ctx);
  BN_CTX_free(ctx);
  return result;
}

- (BigInteger *)modulo:(BigInteger *)other {
  BN_CTX *ctx = BN_CTX_new();
  BigInteger *result = [[BigInteger alloc] init];
  BN_mod(result.bn, _bn, other.bn, ctx);
  BN_CTX_free(ctx);
  return result;
}

- (BigInteger *)shiftLeft:(int)bits {
  BigInteger *result = [[BigInteger alloc] init];
  BN_lshift(result.bn, _bn, bits);
  return result;
}

- (BigInteger *)shiftRight:(int)bits {
  BigInteger *result = [[BigInteger alloc] init];
  BN_rshift(result.bn, _bn, bits);
  return result;
}

- (BOOL)isEqual:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) == 0;
}

- (BOOL)greaterThan:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) > 0;
}

- (BOOL)greaterThanOrEqual:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) >= 0;
}

- (BOOL)lessThan:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) < 0;
}

- (BOOL)lessThanOrEqual:(BigInteger *)other {
  return BN_cmp(_bn, other.bn) <= 0;
}

@end
