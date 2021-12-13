// The Ideal Stocking Stuffer
// https://adventofcode.com/2015/day/4

#include <stdio.h>
#include <string.h>
#include <CommonCrypto/CommonDigest.h>

// Compares the given number of nibbles (half-byte / semi-octet) of data with 0.
// Returns 0 if they are all equal to 0, otherwise returns -1.
int compareNibblesToZero(unsigned char data[], int count) {
    int byteIndex = 0;
    while (count > 4) {
        if (*((int16_t *)(data+byteIndex)) != 0) {
            return -1;
        }
        count -= 4;
        byteIndex += 2;
    }
    unsigned char lastByte = *(data+byteIndex);
    if (count == 1) {
        lastByte &= 0xf0;
    }
    return lastByte == 0 ? 0 : -1;
}

int mineAdventCoin(const char secret_key[], int leading_digits)
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    char attempt[CC_MD5_DIGEST_LENGTH * 2] = {0};

    for (int value = 1; ; value++) {
        sprintf(attempt, "%s%d", secret_key, value);

        CC_MD5_CTX context;
        CC_MD5_Init(&context);
        CC_MD5_Update(&context, attempt, (CC_LONG)strlen(attempt));
        CC_MD5_Final(digest, &context);

        if (compareNibblesToZero(digest, leading_digits) == 0) {
            return value;
        }
    }
}

int main()
{
    const char secret_key[] = "iwrupvqb";
    
    int result = mineAdventCoin(secret_key, 5);
    printf("Part 1: %d\n", result);

    result = mineAdventCoin(secret_key, 6);
    printf("Part 2: %d\n", result);

    return 0;
}