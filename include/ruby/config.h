#pragma once
#ifndef __CRUBY_RUBY_CONFIG_H__
#define __CRUBY_RUBY_CONFIG_H__


#import <TargetConditionals.h>


#if TARGET_OS_IOS
	#if TARGET_OS_SIMULATOR
		#ifdef __x86_64__
		#include "ruby/config-iphonesimulator-x86_64.h"
		#endif

		#ifdef __arm64__
		#include "ruby/config-iphonesimulator-arm64.h"
		#endif
	#else
		#ifdef __x86_64__
		#include "ruby/config-iphoneos-x86_64.h"
		#endif

		#ifdef __arm64__
		#include "ruby/config-iphoneos-arm64.h"
		#endif
	#endif
#else
	#ifdef __x86_64__
	#include "ruby/config-macosx-x86_64.h"
	#endif

	#ifdef __arm64__
	#include "ruby/config-macosx-arm64.h"
	#endif
#endif


#endif//EOH
