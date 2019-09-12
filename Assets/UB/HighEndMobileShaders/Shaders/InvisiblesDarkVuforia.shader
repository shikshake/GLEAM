﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UB/InvisiblesDarkVuforia" 
{
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _TextureRatioX ("TextureRatioX", Float) = 0.0
        _TextureRatioY ("TextureRatioY", Float) = 0.0
        _ViewportSizeX ("ViewportSizeX", Float) = 0.0
        _ViewportSizeY ("ViewportSizeY", Float) = 0.0
        _ViewportOrigX ("ViewportOrigX", Float) = 0.0
        _ViewportOrigY ("ViewportOrigY", Float) = 0.0
        _ScreenWidth ("ScreenWidth", Float) = 0.0
        _ScreenHeight ("ScreenHeight", Float) = 0.0
        _PrefixX ("PrefixX", Float) = 0.0
        _PrefixY ("PrefixY", Float) = 0.0
        _InversionMultiplierX ("InversionMultiplierX", Float) = 0.0
        _InversionMultiplierY ("InversionMultiplierY", Float) = 0.0
    }
    SubShader {
        //Tags {"Queue"="overlay+4" "RenderType"="overlay" }
        Tags { 
            "RenderType" = "Opaque"
        }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Mine fullforwardshadows
        #pragma multi_compile PORTRAIT_ON PORTRAIT_OFF

        sampler2D _MainTex;
        float _TextureRatioX;
        float _TextureRatioY;
        float _ViewportSizeX;
        float _ViewportSizeY;
        float _ViewportOrigX;
        float _ViewportOrigY;
        float _ScreenWidth;
        float _ScreenHeight;
        float _PrefixX;
        float _PrefixY;
        float _InversionMultiplierX;
        float _InversionMultiplierY;

        struct Input {
            float2 uv_MainTex;
            float4 screenPos;
        };

        half4 LightingMine (SurfaceOutput s, half3 lightDir, half atten) {
            //half NdotL = dot (s.Normal, lightDir);
            //half4 c; 
            //c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten * 2);
            //c.a = s.Alpha;
            //return c;
            half NdotL = dot (s.Normal, lightDir);
            half4 c; 
            c.rgb = s.Albedo * _LightColor0.rgb * atten;
            c.a = s.Alpha;
            return c;
        }

        #define FLT_MAX 3.402823466e+38
        #define FLT_MIN 1.175494351e-38
        #define DBL_MAX 1.7976931348623158e+308
        #define DBL_MIN 2.2250738585072014e-308

        void surf (Input IN, inout SurfaceOutput o) {
            float2 currentFragCoord;
            float2 screenCoord;

            // Convert from unity coordinates to viewport coordinates
            currentFragCoord.xy = float2(_ScreenWidth, _ScreenHeight) * (IN.screenPos.xy/IN.screenPos.w+FLT_MIN);     

            float normalized_coordinates[2];

            // The following equations calculate the appropriate UV coordinates
            // to take from the video sampler. They consider whether the screen
            // is in landscape or portrait mode and whether it uses the front (reflected)
            // or back camera. The actual coefficients are passed by BoxSetUpShader.cs.
            
            normalized_coordinates[0] = (currentFragCoord.x-_ViewportOrigX)/_ViewportSizeX;
            normalized_coordinates[1] = (currentFragCoord.y-_ViewportOrigY)/_ViewportSizeY; 

            // convert from viewport coordinates to screen_texture coordinates
            #ifdef PORTRAIT_ON
                screenCoord.x = (_PrefixX + (_InversionMultiplierX * normalized_coordinates[1])) * _TextureRatioX;
                screenCoord.y = (_PrefixY + (_InversionMultiplierY * normalized_coordinates[0])) * _TextureRatioY;
            #else
                screenCoord.x = (_PrefixX + (_InversionMultiplierX * normalized_coordinates[0])) * _TextureRatioX;
                screenCoord.y = (_PrefixY + (_InversionMultiplierY * normalized_coordinates[1])) * _TextureRatioY;
            #endif

            // Get the video color given the screen's coordinates
            half4 video = tex2D (_MainTex, screenCoord.xy);

            // Uses the texture from the video and the transparency computed above
            o.Albedo = video.rgb;
            o.Alpha = 1;
        }
        ENDCG
    } 
    FallBack "Diffuse"
}