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

#define BCRYPT_WORDS 6

bf_init(blf_ctx *c)
bf_expand(blf_ctx *c, const uint8_t *data, uint16_t databytes,
		const uint8_t *key, uint16_t keybytes);
bf_expand0(blf_ctx *c, const uint8_t *key, uint16_t keybytes);
bf_encrypt(blf_ctx *c)

static ERL_NIF_TERM bf_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	if (!enif_inspect_binary(env, argv[0], &state)) {
		return enif_make_badarg(env);
	}

	Blowfish_initstate(&state);
}

static ERL_NIF_TERM bf_expand(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	if (!enif_inspect_binary(env, argv[0], &state)) {
		return enif_make_badarg(env);
	}

	Blowfish_expandstate(&state, csalt, salt_len,
			(u_int8_t *) key, key_len);
}

static ERL_NIF_TERM bf_expand0(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	if (!enif_inspect_binary(env, argv[0], &state)) {
		return enif_make_badarg(env);
	}

	Blowfish_expand0state(&state, (u_int8_t *) key, key_len);
	Blowfish_expand0state(&state, csalt, salt_len);
}

static ERL_NIF_TERM bf_encrypt(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
	i, k;
	cdata;
	ciphertext;

	if (!enif_inspect_binary(env, argv[0], &state)) {
		return enif_make_badarg(env);
	}

	j = 0;
	for (i = 0; i < BCRYPT_WORDS; i++)
		cdata[i] = Blowfish_stream2word(ciphertext, 4 * BCRYPT_WORDS, &j);

	/* Now do the encryption */
	for (k = 0; k < 64; k++)
		blf_enc(&state, cdata, BCRYPT_WORDS / 2);

	for (i = 0; i < BCRYPT_WORDS; i++) {
		ciphertext[4 * i + 3] = cdata[i] & 0xff;
		cdata[i] = cdata[i] >> 8;
		ciphertext[4 * i + 2] = cdata[i] & 0xff;
		cdata[i] = cdata[i] >> 8;
		ciphertext[4 * i + 1] = cdata[i] & 0xff;
		cdata[i] = cdata[i] >> 8;
		ciphertext[4 * i + 0] = cdata[i] & 0xff;
	}
}

static ErlNifFunc bcrypt_nif_funcs[] =
{
	{"bf_init", 2, bf_init},
	{"bf_expand", 2, bf_expand},
	{"bf_expand0", 2, bf_expand0},
	{"bf_encrypt", 2, bf_encrypt}
};

ERL_NIF_INIT(Elixir.Comeonin.Bcrypt, bcrypt_nif_funcs, NULL, NULL, NULL, NULL)
