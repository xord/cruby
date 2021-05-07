#pragma once
#ifndef __CRUBY_RUBY_CONFIG_H__
#define __CRUBY_RUBY_CONFIG_H__


#import <TargetConditionals.h>


#if TARGET_OS_IPHONE
	#ifdef __x86_64__
	#include "ruby/config-ios_x86_64.h"
	#endif

	#ifdef __arm64__
	#include "ruby/config-ios_arm64.h"
	#endif
#else
	#ifdef __x86_64__
	#include "ruby/config-macos_x86_64.h"
	#endif

	#ifdef __arm64__
	#include "ruby/config-macos_arm64.h"
	#endif
#endif


#endif//EOH
