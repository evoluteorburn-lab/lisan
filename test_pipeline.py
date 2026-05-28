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
    Pipeline: Text (RU) -> Translation (AR) -> Explanation
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
            "max_tokens": 500,
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


def test_full_pipeline():
    """Test translation + explanation with DeepL + DeepSeek"""
    print("=" * 70)
    print("LISAN - FULL PIPELINE TEST (DeepL + DeepSeek)")
    print("=" * 70)
    print()
    
    translator = LisanTranslator()
    
    # Test phrases
    test_phrases = [
        "Привет",
        "Как дела?",
        "Спасибо",
        "Сколько стоит?",
        "Где ресторан?",
    ]
    
    print(f"Testing {len(test_phrases)} phrases with translation + explanation...")
    print("-" * 70)
    
    results = []
    
    for i, phrase in enumerate(test_phrases, 1):
        print(f"\n{i}. Testing: '{phrase}'")
        print("   " + "-" * 50)
        
        # Step 1: Translate
        start_time = time.time()
        translation = translator.translate_with_deepl(phrase, "RU", "AR")
        trans_time = time.time() - start_time
        
        if "error" in translation:
            print(f"   ❌ Translation Error: {translation['error']}")
            results.append({"phrase": phrase, "status": "error", "error": translation["error"]})
            continue
        
        translated = translation["translated_text"]
        print(f"   ✅ Translation: {translated}")
        print(f"   ⏱️  Translation time: {trans_time:.2f}s")
        
        # Step 2: Get explanation
        explanation = translator.get_explanation_deepseek(phrase, translated, "Arabic")
        
        if "error" in explanation:
            print(f"   ❌ Explanation Error: {explanation['error']}")
            results.append({
                "phrase": phrase,
                "status": "partial",
                "translation": translated,
                "error": explanation["error"]
            })
            continue
        
        print(f"   ✅ Explanation received ({explanation['time']:.2f}s)")
        print(f"\n   📚 EXPLANATION:")
        print("   " + "=" * 50)
        
        # Format explanation
        explanation_text = explanation["explanation"]
        for line in explanation_text.split('\n'):
            if line.strip():
                print(f"   {line}")
        
        print("   " + "=" * 50)
        
        results.append({
            "phrase": phrase,
            "status": "success",
            "translation": translated,
            "explanation": explanation_text,
            "translation_time": trans_time,
            "explanation_time": explanation["time"]
        })
    
    # Summary
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    
    success_count = sum(1 for r in results if r["status"] == "success")
    partial_count = sum(1 for r in results if r["status"] == "partial")
    error_count = sum(1 for r in results if r["status"] == "error")
    
    print(f"Total: {len(results)}")
    print(f"Full success (translation + explanation): {success_count} ✅")
    print(f"Partial (translation only): {partial_count} ⚠️")
    print(f"Errors: {error_count} ❌")
    
    if success_count > 0:
        avg_trans_time = sum(r["translation_time"] for r in results if r["status"] == "success") / success_count
        avg_exp_time = sum(r["explanation_time"] for r in results if r["status"] == "success") / success_count
        print(f"\nAverage translation time: {avg_trans_time:.2f}s")
        print(f"Average explanation time: {avg_exp_time:.2f}s")
        print(f"Average total time: {avg_trans_time + avg_exp_time:.2f}s")
    
    return results


if __name__ == "__main__":
    results = test_full_pipeline()
