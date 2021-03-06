/*
 * Copyright (C) 2011-2021 Intel Corporation. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Intel Corporation nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


/*
 * Description:
 *     The file provides `enclave_entry' function to switch code between
 * trusted and untrusted envronment.
 */

    .file "trts_pic.S"

#include "linux-regs.h"

/* 
 * ------------------------------------------------------------------------
 * extern "C" int do_egetkey(key_request_t *key_request, key_128bit_t *key)
 * return value:
 *	0 - success
 *	none-zeor - EGETKEY error code
 * EGETKEY: rbx - the address of KEYREQUEST structure
 *	   rcx - the address where the key is outputted
 * ------------------------------------------------------------------------
 */
DECLARE_LOCAL_FUNC do_egetkey
    SE_PROLOG
    mov  $SE_EGETKEY, %xax      /* EGETKEY leaf */
    ENCLU
#ifdef SE_SIM
    cmp  $SGX_SUCCESS, %xax     /* In simulation mode, ZF flag will not be set */
    jnz	 .Legetkey_done         /* because the stack clean operation will always clean ZF flag */
#else
    jz   .Legetkey_done         /* if EGETKEY error, ZF flag is set and error code is set to xax */
#endif
    xor  %xax, %xax
.Legetkey_done:
    SE_EPILOG


/* 
 * -------------------------------------------------------------------------
 * extern "C" int do_ereport(sgx_target_info_t *target_info, sgx_report_data_t *report_data, sgx_report_t *report);
 * EREPORT: rbx - the address of TARGETINFO;
 *          rcx - the address of REPORTDATA;
 *          rdx - the address where REPORT is outputted
 * return value:
 *          zero: success
 *          non-zero: failure
 * -------------------------------------------------------------------------
 */
.global Lereport_inst
DECLARE_LOCAL_FUNC do_ereport
    SE_PROLOG
    mov       $SE_EREPORT, %xax  /* EREPORT leaf */
    clc
Lereport_inst:
    ENCLU
    setc      %al
    SE_EPILOG
