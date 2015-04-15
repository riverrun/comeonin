/*
 * Copyright (c) 2011 Hunter Morris <hunter.morris@smarkets.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "erl_nif.h"
#include "erl_blf.h"

#define BCRYPT_MAXSALT 16
#define BCRYPT_WORDS 6

void Blowfish_initstate(blf_ctx *c);
void Blowfish_expandstate(blf_ctx *c, const uint8_t *data, uint16_t databytes,
		const uint8_t *key, uint16_t keybytes);
void Blowfish_expand0state(blf_ctx *c, const uint8_t *key, uint16_t keybytes);
uint32_t Blowfish_stream2word(const uint8_t *data, uint16_t databytes, uint16_t *current);
void blf_enc(blf_ctx *c, uint32_t *data, uint16_t blocks);

static ERL_NIF_TERM bf_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary state;
	char key[1024];
	char salt[BCRYPT_MAXSALT];
	size_t key_len;
	unsigned long key_len_arg;
	uint8_t salt_len;

	if (argc != 3 || !enif_get_string(env, argv[0], key, sizeof(key), ERL_NIF_LATIN1) ||
			!enif_get_ulong(env, argv[1], &key_len_arg) ||
			!enif_get_string(env, argv[2], salt, sizeof(salt), ERL_NIF_LATIN1))
		return enif_make_badarg(env);
	key_len = (size_t) key_len_arg;
	salt_len = BCRYPT_MAXSALT;

	if (!enif_alloc_binary(sizeof(blf_ctx), &state))
		return enif_make_badarg(env);

	Blowfish_initstate((blf_ctx *) state.data);
	Blowfish_expandstate((blf_ctx *) state.data, (uint8_t *) salt,
			salt_len, (uint8_t *) key, key_len);

	return enif_make_binary(env, &state);
}

static ERL_NIF_TERM bf_expand(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary state;
	char key[1024];
	char salt[BCRYPT_MAXSALT];
	size_t key_len;
	unsigned long key_len_arg;
	uint8_t salt_len;

	if (argc != 4 || !enif_inspect_binary(env, argv[0], &state))
		return enif_make_badarg(env);
	if (!enif_get_string(env, argv[1], key, sizeof(key), ERL_NIF_LATIN1) ||
			!enif_get_ulong(env, argv[2], &key_len_arg) ||
			!enif_get_string(env, argv[3], salt, sizeof(salt), ERL_NIF_LATIN1))
		return enif_make_badarg(env);
	key_len = (size_t) key_len_arg;
	salt_len = BCRYPT_MAXSALT;

	Blowfish_expand0state((blf_ctx *) state.data, (uint8_t *) key, key_len);
	Blowfish_expand0state((blf_ctx *) state.data, (uint8_t *) salt, salt_len);

	return enif_make_binary(env, &state);
}

static ERL_NIF_TERM bf_encrypt(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary state;
	uint32_t i, k;
	uint16_t j;
	uint8_t ciphertext[4 * BCRYPT_WORDS] = "OrpheanBeholderScryDoubt";
	uint32_t cdata[BCRYPT_WORDS];
	char encrypted[24];

	/* Initialize our data from argv */
	if (argc != 1 || !enif_inspect_binary(env, argv[0], &state))
		return enif_make_badarg(env);

	/* This can be precomputed later */
	j = 0;
	for (i = 0; i < BCRYPT_WORDS; i++)
		cdata[i] = Blowfish_stream2word(ciphertext, 4 * BCRYPT_WORDS, &j);

	/* Now do the encryption */
	for (k = 0; k < 64; k++)
		blf_enc((blf_ctx *) state.data, cdata, BCRYPT_WORDS / 2);

	for (i = 0; i < BCRYPT_WORDS; i++) {
		ciphertext[4 * i + 3] = cdata[i] & 0xff;
		cdata[i] = cdata[i] >> 8;
		ciphertext[4 * i + 2] = cdata[i] & 0xff;
		cdata[i] = cdata[i] >> 8;
		ciphertext[4 * i + 1] = cdata[i] & 0xff;
		cdata[i] = cdata[i] >> 8;
		ciphertext[4 * i + 0] = cdata[i] & 0xff;
	}

	snprintf(encrypted, 24, (const char *) ciphertext);
	return enif_make_string(env, encrypted, ERL_NIF_LATIN1);
}

static ErlNifFunc bcrypt_nif_funcs[] =
{
	{"bf_init", 3, bf_init},
	{"bf_expand", 4, bf_expand},
	{"bf_encrypt", 1, bf_encrypt}
};

ERL_NIF_INIT(Elixir.Comeonin.Bcrypt, bcrypt_nif_funcs, NULL, NULL, NULL, NULL)
