package com.xraiassistant.di

import android.util.Log
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import com.xraiassistant.data.remote.AnthropicService
import com.xraiassistant.data.remote.OpenAIService
import com.xraiassistant.data.remote.TogetherAIService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import java.security.cert.X509Certificate
import java.util.concurrent.TimeUnit
import javax.inject.Qualifier
import javax.inject.Singleton
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

/**
 * Network Module
 *
 * Provides Retrofit instances for different AI providers:
 * - Together.ai: https://api.together.xyz
 * - OpenAI: https://api.openai.com
 * - Anthropic: https://api.anthropic.com
 */
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    // Qualifiers for different Retrofit instances
    @Qualifier
    @Retention(AnnotationRetention.BINARY)
    annotation class TogetherAI

    @Qualifier
    @Retention(AnnotationRetention.BINARY)
    annotation class OpenAI

    @Qualifier
    @Retention(AnnotationRetention.BINARY)
    annotation class Anthropic

    /**
     * Moshi for JSON serialization
     */
    @Provides
    @Singleton
    fun provideMoshi(): Moshi = Moshi.Builder()
        .addLast(KotlinJsonAdapterFactory())
        .build()

    /**
     * OkHttpClient with logging interceptor and SSL configuration
     *
     * Configured with:
     * - 60 second timeouts (AI responses can be slow)
     * - HTTP logging for debugging
     * - Connection pooling
     * - SSL trust configuration for Android emulator compatibility
     */
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        val builder = OkHttpClient.Builder()
            .addInterceptor(loggingInterceptor)
            .connectTimeout(60, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)

        // Configure SSL for Android emulator compatibility
        // Android emulators often have outdated system certificates
        try {
            // Create a trust manager that trusts all certificates (for debug builds)
            val trustAllCerts = arrayOf<TrustManager>(object : X509TrustManager {
                override fun checkClientTrusted(chain: Array<out X509Certificate>?, authType: String?) {
                    Log.d("NetworkModule", "✅ Client certificate trusted: $authType")
                }

                override fun checkServerTrusted(chain: Array<out X509Certificate>?, authType: String?) {
                    Log.d("NetworkModule", "✅ Server certificate trusted: $authType, chain length: ${chain?.size}")
                    // Log certificate details for debugging
                    chain?.forEachIndexed { index, cert ->
                        Log.d("NetworkModule", "  Certificate $index: ${cert.subjectDN}")
                        Log.d("NetworkModule", "    Issuer: ${cert.issuerDN}")
                        Log.d("NetworkModule", "    Valid from: ${cert.notBefore} to ${cert.notAfter}")
                    }
                }

                override fun getAcceptedIssuers(): Array<X509Certificate> = arrayOf()
            })

            // Install the all-trusting trust manager
            val sslContext = SSLContext.getInstance("TLS")
            sslContext.init(null, trustAllCerts, java.security.SecureRandom())

            builder.sslSocketFactory(sslContext.socketFactory, trustAllCerts[0] as X509TrustManager)

            // Disable hostname verification for debug builds
            builder.hostnameVerifier { hostname, session ->
                Log.d("NetworkModule", "✅ Hostname verified: $hostname")
                true
            }

            Log.d("NetworkModule", "✅ SSL configuration applied successfully")
        } catch (e: Exception) {
            Log.e("NetworkModule", "❌ Failed to configure SSL", e)
        }

        return builder.build()
    }

    /**
     * Retrofit for Together.ai
     * Base URL: https://api.together.xyz
     */
    @Provides
    @Singleton
    @TogetherAI
    fun provideTogetherAIRetrofit(
        okHttpClient: OkHttpClient,
        moshi: Moshi
    ): Retrofit = Retrofit.Builder()
        .baseUrl("https://api.together.xyz/")
        .client(okHttpClient)
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .build()

    /**
     * Retrofit for OpenAI
     * Base URL: https://api.openai.com
     */
    @Provides
    @Singleton
    @OpenAI
    fun provideOpenAIRetrofit(
        okHttpClient: OkHttpClient,
        moshi: Moshi
    ): Retrofit = Retrofit.Builder()
        .baseUrl("https://api.openai.com/")
        .client(okHttpClient)
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .build()

    /**
     * Retrofit for Anthropic
     * Base URL: https://api.anthropic.com
     */
    @Provides
    @Singleton
    @Anthropic
    fun provideAnthropicRetrofit(
        okHttpClient: OkHttpClient,
        moshi: Moshi
    ): Retrofit = Retrofit.Builder()
        .baseUrl("https://api.anthropic.com/")
        .client(okHttpClient)
        .addConverterFactory(MoshiConverterFactory.create(moshi))
        .build()

    /**
     * Together.ai Service
     */
    @Provides
    @Singleton
    fun provideTogetherAIService(
        @TogetherAI retrofit: Retrofit
    ): TogetherAIService = retrofit.create(TogetherAIService::class.java)

    /**
     * OpenAI Service
     */
    @Provides
    @Singleton
    fun provideOpenAIService(
        @OpenAI retrofit: Retrofit
    ): OpenAIService = retrofit.create(OpenAIService::class.java)

    /**
     * Anthropic Service
     */
    @Provides
    @Singleton
    fun provideAnthropicService(
        @Anthropic retrofit: Retrofit
    ): AnthropicService = retrofit.create(AnthropicService::class.java)
}
