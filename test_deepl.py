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
    Pipeline: Speech (RU) -> Text -> Translation (AR) -> Explanation -> Voice
    """
    
    def __init__(self):
        self.openai_key = OPENAI_API_KEY
        self.deepl_key = DEEPL_API_KEY
        self.elevenlabs_key = ELEVENLABS_API_KEY
        self.deepseek_key = DEEPSEEK_API_KEY
        
    def translate_with_deepl(self, text: str, source_lang: str = "RU", target_lang: str = "AR") -> dict:
        """
        Translate text using DeepL API
        """
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
        """
        Get detailed explanation from DeepSeek
        """
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
            "max_tokens": 500,
            "temperature": 0.7
        }
        
        try:
            response = requests.post(url, headers=headers, json=data, timeout=15)
            response.raise_for_status()
            result = response.json()
            return {
                "explanation": result["choices"][0]["message"]["content"],
                "model": "deepseek-chat"
            }
        except Exception as e:
            return {"error": f"DeepSeek explanation failed: {str(e)}"}
    
    def text_to_speech_elevenlabs(self, text: str, language: str = "arabic") -> dict:
        """
        Convert text to speech using ElevenLabs
        """
        if not self.elevenlabs_key:
            return {"error": "ElevenLabs API key not set"}
            
        # Voice IDs for different languages
        voice_map = {
            "arabic": "XB0fDUnXU5powFXDhCwa",  # Generic Arabic voice
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
            response = requests.post(url, headers=headers, json=data, timeout=15)
            response.raise_for_status()
            
            # Save audio file
            audio_path = f"/tmp/lisan_tts_{language}.mp3"
            with open(audio_path, "wb") as f:
                f.write(response.content)
            
            return {
                "audio_path": audio_path,
                "status": "success"
            }
        except Exception as e:
            return {"error": f"TTS failed: {str(e)}"}
    
    def full_pipeline(self, text: str, source_lang: str = "RU", target_lang: str = "AR") -> dict:
        """
        Complete pipeline: translate + explain + TTS
        """
        print(f"🎤 Input: {text}")
        
        # Step 1: Translate
        print("🔄 Translating...")
        translation = self.translate_with_deepl(text, source_lang, target_lang)
        if "error" in translation:
            return translation
        
        translated = translation["translated_text"]
        print(f"✅ Translation: {translated}")
        
        # Step 2: Get explanation
        print("🧠 Getting explanation...")
        explanation = self.get_explanation_deepseek(text, translated, "Arabic")
        if "error" in explanation:
            return explanation
        
        print(f"✅ Explanation received")
        
        # Step 3: Text to speech
        print("🔊 Generating voice...")
        tts = self.text_to_speech_elevenlabs(translated, "arabic")
        
        return {
            "original": text,
            "translated": translated,
            "explanation": explanation["explanation"],
            "audio": tts.get("audio_path", "N/A"),
            "status": "success"
        }


def test_translation_only():
    """
    Test DeepL translation with the provided API key
    """
    print("=" * 60)
    print("LISAN - DEEP TRANSLATION TEST")
    print("=" * 60)
    print()
    
    translator = LisanTranslator()
    
    # Test phrases
    test_phrases = [
        "Привет",
        "Как дела?",
        "Спасибо",
        "Сколько стоит?",
        "Где ресторан?",
        "До свидания",
        "Я не понимаю",
        "Повторите, пожалуйста"
    ]
    
    print(f"Testing {len(test_phrases)} phrases...")
    print("-" * 60)
    
    results = []
    
    for i, phrase in enumerate(test_phrases, 1):
        print(f"\n{i}. Testing: '{phrase}'")
        start_time = time.time()
        
        result = translator.translate_with_deepl(phrase, "RU", "AR")
        
        elapsed = time.time() - start_time
        
        if "error" in result:
            print(f"   ❌ Error: {result['error']}")
            results.append({"phrase": phrase, "status": "error", "error": result["error"]})
        else:
            print(f"   ✅ Translation: {result['translated_text']}")
            print(f"   ⏱️  Time: {elapsed:.2f}s")
            results.append({
                "phrase": phrase,
                "status": "success",
                "translation": result["translated_text"],
                "time": elapsed
            })
    
    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    success_count = sum(1 for r in results if r["status"] == "success")
    error_count = len(results) - success_count
    avg_time = sum(r.get("time", 0) for r in results if r["status"] == "success") / max(success_count, 1)
    
    print(f"Total: {len(results)}")
    print(f"Success: {success_count} ✅")
    print(f"Errors: {error_count} ❌")
    print(f"Average time: {avg_time:.2f}s")
    
    if success_count > 0:
        print("\nSample translations:")
        for r in results[:3]:
            if r["status"] == "success":
                print(f"  '{r['phrase']}' -> '{r['translation']}'")
    
    return results


if __name__ == "__main__":
    results = test_translation_only()
