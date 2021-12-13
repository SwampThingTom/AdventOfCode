// The Ideal Stocking Stuffer
// https://adventofcode.com/2015/day/4

#include <stdio.h>
#include <string.h>
#include <CommonCrypto/CommonDigest.h>

int mineAdventCoin(const char secret_key[], int leading_digits)
{
    static const char success[] = "0000000000000000";
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    char attempt[CC_MD5_DIGEST_LENGTH * 2] = {0};
    char result[CC_MD5_DIGEST_LENGTH * 2] = {0};

    for (int value = 1; ; value++) {
        sprintf(attempt, "%s%d", secret_key, value);

        CC_MD5_CTX context;
        CC_MD5_Init(&context);
        CC_MD5_Update(&context, attempt, (CC_LONG)strlen(attempt));
        CC_MD5_Final(digest, &context);

        for (size_t i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            sprintf(result + i * 2, "%.2x", digest[i]);
        }

        if (memcmp(result, success, leading_digits) == 0) {
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