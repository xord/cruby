#pragma once
#ifndef __CRUBY_RUBY_CONFIG_H__
#define __CRUBY_RUBY_CONFIG_H__


#import <TargetConditionals.h>


#if TARGET_OS_IPHONE
	#ifdef __i386__
	#include "ruby/config-ios_i386.h"
	#endif

	#ifdef __x86_64__
	#include "ruby/config-ios_x86_64.h"
	#endif

	#ifdef __ARM_ARCH_7A__
	#include "ruby/config-ios_armv7.h"
	#endif

	#ifdef __ARM_ARCH_7S__
	#include "ruby/config-ios_armv7s.h"
	#endif

	#ifdef __arm64__
	#include "ruby/config-ios_arm64.h"
	#endif
#else
	#ifdef __i386__
	#include "ruby/config-osx_i386.h"
	#endif

	#ifdef __x86_64__
	#include "ruby/config-osx_x86_64.h"
	#endif
#endif


#endif//EOH
