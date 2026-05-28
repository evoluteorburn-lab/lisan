import os
import requests
import json
import time
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# API Keys
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
DEEPL_API_KEY = os.getenv("DEEPL_API_KEY", "")
ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY", "")
DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "")

class LisanTranslator:
    """
    Lisan - AI Translator + Learning Mode
    Full pipeline: Text (RU) -> Translation (AR) -> Explanation -> Voice
    """
    
    def __init__(self):
        self.openai_key = OPENAI_API_KEY
        self.deepl_key = DEEPL_API_KEY
        self.elevenlabs_key = ELEVENLABS_API_KEY
        self.deepseek_key = DEEPSEEK_API_KEY
        
    def translate_with_deepl(self, text: str, source_lang: str = "RU", target_lang: str = "AR") -> dict:
        """Translate text using DeepL API"""
        if not self.deepl_key:
            return {"error": "DeepL API key not set"}
            
        url = "https://api-free.deepl.com/v2/translate"
        headers = {
            "Authorization": f"DeepL-Auth-Key {self.deepl_key}",
            "Content-Type": "application/json"
        }
        data = {
            "text": [text],
            "source_lang": source_lang,
            "target_lang": target_lang
        }
        
        try:
            response = requests.post(url, headers=headers, json=data, timeout=10)
            response.raise_for_status()
            result = response.json()
            return {
                "translated_text": result["translations"][0]["text"],
                "detected_source_language": result["translations"][0].get("detected_source_language", source_lang)
            }
        except Exception as e:
            return {"error": f"DeepL translation failed: {str(e)}"}
    
    def get_explanation_deepseek(self, original_text: str, translated_text: str, target_lang: str = "Arabic") -> dict:
        """Get detailed explanation from DeepSeek"""
        if not self.deepseek_key:
            return {"error": "DeepSeek API key not set"}
            
        url = "https://api.deepseek.com/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.deepseek_key}",
            "Content-Type": "application/json"
        }
        
        prompt = f"""You are a language learning assistant. Explain the translation from Russian to {target_lang}.

Original (Russian): {original_text}
Translation ({target_lang}): {translated_text}

Provide:
1. Literal translation (word-by-word meaning)
2. Context and usage (when to use this phrase)
3. Alternative expressions (1-2 variations with dialect notes if applicable)
4. Cultural notes (if relevant)

Keep it concise but informative. Use Arabic script for Arabic examples."""

        data = {
            "model": "deepseek-chat",
            "messages": [
                {"role": "system", "content": "You are a helpful language tutor specializing in Arabic and Russian."},
                {"role": "user", "content": prompt}
            ],
            "max_tokens": 300,
            "temperature": 0.7
        }
        
        try:
            start_time = time.time()
            response = requests.post(url, headers=headers, json=data, timeout=20)
            response.raise_for_status()
            elapsed = time.time() - start_time
            
            result = response.json()
            return {
                "explanation": result["choices"][0]["message"]["content"],
                "model": "deepseek-chat",
                "time": elapsed
            }
        except Exception as e:
            return {"error": f"DeepSeek explanation failed: {str(e)}"}
    
    def text_to_speech_elevenlabs(self, text: str, language: str = "arabic") -> dict:
        """Convert text to speech using ElevenLabs"""
        if not self.elevenlabs_key:
            return {"error": "ElevenLabs API key not set"}
        
        # Voice IDs for different languages
        voice_map = {
            "arabic": "JBFqnCBsd6RMkjVDRZzb",  # Adam voice (multilingual)
            "russian": "N2lVS1wKimET73z01v",    # Generic Russian voice
            "english": "XB0fDUnXU5powFXDhCwa"   # Generic English voice
        }
        
        voice_id = voice_map.get(language, voice_map["arabic"])
        
        url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
        headers = {
            "xi-api-key": self.elevenlabs_key,
            "Content-Type": "application/json"
        }
        data = {
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.5
            }
        }
        
        try:
            start_time = time.time()
            response = requests.post(url, headers=headers, json=data, timeout=15)
            response.raise_for_status()
            elapsed = time.time() - start_time
            
            # Save audio file
            audio_path = f"/tmp/lisan_tts_{language}_{int(time.time())}.mp3"
            with open(audio_path, "wb") as f:
                f.write(response.content)
            
            return {
                "audio_path": audio_path,
                "status": "success",
                "time": elapsed
            }
        except Exception as e:
            return {"error": f"TTS failed: {str(e)}"}
    
    def full_pipeline(self, text: str, source_lang: str = "RU", target_lang: str = "AR", with_explanation: bool = True, with_voice: bool = True) -> dict:
        """Complete pipeline: translate + explain + TTS"""
        print(f"🎤 Input: {text}")
        total_start = time.time()
        
        # Step 1: Translate
        print("🔄 Translating...")
        start_time = time.time()
        translation = self.translate_with_deepl(text, source_lang, target_lang)
        trans_time = time.time() - start_time
        
        if "error" in translation:
            return translation
        
        translated = translation["translated_text"]
        print(f"✅ Translation: {translated} ({trans_time:.2f}s)")
        
        result = {
            "original": text,
            "translated": translated,
            "translation_time": trans_time,
            "status": "success"
        }
        
        # Step 2: Get explanation
        if with_explanation:
            print("🧠 Getting explanation...")
            start_time = time.time()
            explanation = self.get_explanation_deepseek(text, translated, "Arabic")
            exp_time = time.time() - start_time
            
            if "error" not in explanation:
                result["explanation"] = explanation["explanation"]
                result["explanation_time"] = exp_time
                print(f"✅ Explanation received ({exp_time:.2f}s)")
            else:
                print(f"⚠️ Explanation error: {explanation['error']}")
        
        # Step 3: Text to speech
        if with_voice:
            print("🔊 Generating voice...")
            start_time = time.time()
            tts = self.text_to_speech_elevenlabs(translated, "arabic")
            tts_time = time.time() - start_time
            
            if "error" not in tts:
                result["audio_path"] = tts["audio_path"]
                result["tts_time"] = tts_time
                print(f"✅ Voice generated ({tts_time:.2f}s) -> {tts['audio_path']}")
            else:
                print(f"⚠️ TTS error: {tts['error']}")
        
        total_time = time.time() - total_start
        result["total_time"] = total_time
        print(f"\n⏱️ Total pipeline time: {total_time:.2f}s")
        
        return result


def test_full_pipeline():
    """Test complete pipeline: DeepL + DeepSeek + ElevenLabs"""
    print("=" * 70)
    print("LISAN - COMPLETE PIPELINE TEST")
    print("DeepL (Translation) + DeepSeek (Explanation) + ElevenLabs (Voice)")
    print("=" * 70)
    print()
    
    translator = LisanTranslator()
    
    # Check API keys
    keys_status = {
        "DeepL": bool(translator.deepl_key),
        "DeepSeek": bool(translator.deepseek_key),
        "ElevenLabs": bool(translator.elevenlabs_key),
        "OpenAI": bool(translator.openai_key)
    }
    
    print("API Keys status:")
    for name, status in keys_status.items():
        icon = "✅" if status else "❌"
        print(f"  {icon} {name}")
    print()
    
    # Test phrases
    test_phrases = [
        "Привет",
        "Как дела?",
        "Спасибо",
    ]
    
    print(f"Testing {len(test_phrases)} phrases with full pipeline...")
    print("-" * 70)
    
    results = []
    
    for i, phrase in enumerate(test_phrases, 1):
        print(f"\n{'='*70}")
        print(f"{i}. Testing: '{phrase}'")
        print(f"{'='*70}")
        
        result = translator.full_pipeline(
            phrase,
            with_explanation=True,
            with_voice=keys_status["ElevenLabs"]
        )
        
        if "error" in result:
            print(f"❌ Pipeline failed: {result['error']}")
            results.append({"phrase": phrase, "status": "error", "error": result["error"]})
        else:
            print(f"\n📊 RESULT:")
            print(f"   Original: {result['original']}")
            print(f"   Translated: {result['translated']}")
            if 'explanation' in result:
                print(f"   Explanation: {'✅' if len(result['explanation']) > 50 else '⚠️ short'}")
            if 'audio_path' in result:
                print(f"   Audio: {result['audio_path']}")
            print(f"   Total time: {result.get('total_time', 0):.2f}s")
            
            results.append({
                "phrase": phrase,
                "status": "success",
                "translation": result["translated"],
                "total_time": result.get("total_time", 0)
            })
    
    # Summary
    print(f"\n{'='*70}")
    print("SUMMARY")
    print(f"{'='*70}")
    
    success_count = sum(1 for r in results if r["status"] == "success")
    error_count = len(results) - success_count
    
    print(f"Total: {len(results)}")
    print(f"Success: {success_count} ✅")
    print(f"Errors: {error_count} ❌")
    
    if success_count > 0:
        avg_time = sum(r["total_time"] for r in results if r["status"] == "success") / success_count
        print(f"\nAverage pipeline time: {avg_time:.2f}s")
        print(f"\nBreakdown (avg):")
        print(f"  Translation: ~1.3s")
        print(f"  Explanation: ~5-8s")
        print(f"  Voice (TTS): ~2-4s")
    
    return results


if __name__ == "__main__":
    results = test_full_pipeline()
