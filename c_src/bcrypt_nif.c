/*	$OpenBSD: bcrypt.c,v 1.52 2015/01/28 23:33:52 tedu Exp $	*/

/*
 * Copyright (c) 2014 Ted Unangst <tedu@openbsd.org>
 * Copyright (c) 1997 Niels Provos <provos@umich.edu>
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
/* This password hashing algorithm was designed by David Mazieres
 * <dm@lcs.mit.edu> and works as follows:
 *
 * 1. state := InitState ()
 * 2. state := ExpandKey (state, salt, password)
 * 3. REPEAT rounds:
 *      state := ExpandKey (state, 0, password)
 *	state := ExpandKey (state, 0, salt)
 * 4. ctext := "OrpheanBeholderScryDoubt"
 * 5. REPEAT 64:
 * 	ctext := Encrypt_ECB (state, ctext);
 * 6. RETURN Concatenate (salt, ctext);
 *
 * This version is designed to not allow any NIF to run for too long,
 * and has been implemented by David Whitlock and Jason M Barnes.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef _WIN32
#include <unistd.h>
#endif

#include "erl_nif.h"
#include "erl_blf.h"

#define BCRYPT_MAXSALT 16
#define BCRYPT_WORDS 6
#define	BCRYPT_HASHLEN 23

static void secure_bzero(void *, size_t);

static ERL_NIF_TERM bf_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary state;
	char key[1024];
	char salt[1024];
	uint8_t key_len;
	unsigned long key_len_arg;
	uint8_t salt_len;

	if (argc != 3 || !enif_get_string(env, argv[0], key, sizeof(key), ERL_NIF_LATIN1) ||
			!enif_get_ulong(env, argv[1], &key_len_arg) ||
			!enif_get_string(env, argv[2], salt, sizeof(salt), ERL_NIF_LATIN1))
		return enif_make_badarg(env);
	key_len = key_len_arg;
	salt_len = BCRYPT_MAXSALT;

	if (!enif_alloc_binary(sizeof(blf_ctx), &state))
		return enif_make_badarg(env);

	Blowfish_initstate((blf_ctx *) state.data);
	Blowfish_expandstate((blf_ctx *) state.data, (uint8_t *) salt,
			salt_len, (uint8_t *) key, key_len);

	return enif_make_binary(env, &state);
}

static ERL_NIF_TERM bf_expand0(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary state;
	char key[1024];
	unsigned int key_len;

	if (argc != 3 || !enif_inspect_binary(env, argv[0], &state) ||
			!enif_get_string(env, argv[1], key, sizeof(key), ERL_NIF_LATIN1) ||
			!enif_get_uint(env, argv[2], &key_len))
		return enif_make_badarg(env);

	Blowfish_expand0state((blf_ctx *) state.data, (uint8_t *) key, (uint8_t) key_len);

	return enif_make_binary(env, &state);
}

static ERL_NIF_TERM bf_encrypt(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	ErlNifBinary state;
	uint32_t i, k, m;
	uint16_t j;
	uint8_t ciphertext[4 * BCRYPT_WORDS] = "OrpheanBeholderScryDoubt";
	uint32_t cdata[BCRYPT_WORDS];
	ERL_NIF_TERM encrypted[4 * BCRYPT_WORDS];

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

	for (m = 0; m < BCRYPT_HASHLEN; m++) {
		encrypted[m] = enif_make_uint(env, ciphertext[m]);
	}
	secure_bzero(state.data, state.size);
	enif_release_binary(&state);
	secure_bzero(ciphertext, sizeof(ciphertext));
	secure_bzero(cdata, sizeof(cdata));
	return enif_make_list_from_array(env, encrypted, BCRYPT_HASHLEN);
}

/*
 * A typical memset() or bzero() call can be optimized away due to "dead store
 * elimination" by sufficiently intelligent compilers.  This is a problem for
 * the above bf_encrypt() function which tries to zero-out several temporary
 * buffers before returning.  If these calls get optimized away, then these
 * buffers might leave sensitive information behind.  There are currently no
 * standard, portable functions to handle this issue -- thus the
 * implementation below.
 *
 * This function cannot be optimized away by dead store elimination, but it
 * will be slower than a normal memset() or bzero() call.  Given that the
 * bcrypt algorithm is designed to consume a large amount of time, the change
 * will likely be negligible.
 */
static void secure_bzero(void *buf, size_t len)
{
	if (buf == NULL || len == 0) {
		return;
	}

	volatile unsigned char *ptr = buf;
	while (len--) {
		*ptr++ = 0;
	}
}

static int upgrade(ErlNifEnv* env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
{
	return 0;
}

static ErlNifFunc bcrypt_nif_funcs[] =
{
	{"bf_init", 3, bf_init},
	{"bf_expand0", 3, bf_expand0},
	{"bf_encrypt", 1, bf_encrypt}
};

ERL_NIF_INIT(Elixir.Comeonin.Bcrypt, bcrypt_nif_funcs, NULL, NULL, upgrade, NULL)
