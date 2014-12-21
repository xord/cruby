#pragma once
#ifndef __CRUBY_RUBY_CONFIG_H__
#define __CRUBY_RUBY_CONFIG_H__


#ifdef __i386__
#include "ruby/config.i386.h"
#endif

#ifdef __x86_64__
#include "ruby/config.x86_64.h"
#endif

#ifdef __ARM_ARCH_7A__
#include "ruby/config.armv7.h"
#endif

#ifdef __ARM_ARCH_7S__
#include "ruby/config.armv7s.h"
#endif

#ifdef __arm64__
#include "ruby/config.arm64.h"
#endif


#endif//EOH
