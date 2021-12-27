#pragma once
#ifndef __CRUBY_RUBY_CONFIG_H__
#define __CRUBY_RUBY_CONFIG_H__


#import <CRubyConfig.h>


#if       defined(CRUBY_IPHONESIMULATOR_X86_64)
	#include "ruby/config-iphonesimulator-x86_64.h"
#elif     defined(CRUBY_IPHONESIMULATOR_ARM64)
	#include "ruby/config-iphonesimulator-arm64.h"
#elif     defined(CRUBY_IPHONEOS_X86_64)
	#include "ruby/config-iphoneos-x86_64.h"
#elif     defined(CRUBY_IPHONEOS_ARM64)
	#include "ruby/config-iphoneos-arm64.h"
#elif     defined(CRUBY_MACOSX_X86_64)
	#include "ruby/config-macosx-x86_64.h"
#elif     defined(CRUBY_MACOSX_ARM64)
	#include "ruby/config-macosx-arm64.h"
#endif


#endif//EOH
