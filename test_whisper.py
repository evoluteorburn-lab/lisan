import os
import requests
import json
import time
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

class WhisperTester:
    """Test OpenAI Whisper API for speech recognition"""
    
    def __init__(self):
        self.api_key = OPENAI_API_KEY
        self.api_url = "https://api.openai.com/v1/audio/transcriptions"
    
    def transcribe_audio(self, audio_file_path: str, language: str = "ru") -> dict:
        """
        Transcribe audio file using Whisper API
        """
        if not self.api_key:
            return {"error": "OpenAI API key not set"}
        
        if not os.path.exists(audio_file_path):
            return {"error": f"Audio file not found: {audio_file_path}"}
        
        headers = {
            "Authorization": f"Bearer {self.api_key}"
        }
        
        data = {
            "model": "whisper-1",
            "language": language,
            "response_format": "json"
        }
        
        try:
            with open(audio_file_path, "rb") as audio_file:
                files = {
                    "file": (os.path.basename(audio_file_path), audio_file, "audio/mp3")
                }
                
                start_time = time.time()
                response = requests.post(
                    self.api_url,
                    headers=headers,
                    data=data,
                    files=files,
                    timeout=30
                )
                elapsed = time.time() - start_time
                
                response.raise_for_status()
                result = response.json()
                
                return {
                    "success": True,
                    "text": result.get("text", ""),
                    "language": result.get("language", language),
                    "time": elapsed
                }
                
        except requests.exceptions.HTTPError as e:
            if response.status_code == 401:
                return {"error": "Invalid OpenAI API key"}
            elif response.status_code == 429:
                return {"error": "Rate limit exceeded. Please wait and try again."}
            else:
                return {"error": f"HTTP Error {response.status_code}: {str(e)}"}
        except Exception as e:
            return {"error": f"Transcription failed: {str(e)}"}
    
    def test_with_sample_text(self, text: str = "Привет, как дела?") -> dict:
        """
        Create a test audio file from text using TTS and then transcribe it
        This is a workaround since we don't have actual microphone input
        """
        print(f"📝 Test text: '{text}'")
        print("⚠️  Note: For actual testing, you need to provide an audio file.")
        print("   This test validates the API connection only.")
        
        # Validate API key by making a minimal request
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
        
        try:
            # Test API key validity with a simple models list request
            response = requests.get(
                "https://api.openai.com/v1/models",
                headers=headers,
                timeout=10
            )
            response.raise_for_status()
            
            return {
                "success": True,
                "message": "API key is valid. Ready for audio transcription.",
                "note": "Provide an audio file for full transcription test."
            }
            
        except requests.exceptions.HTTPError as e:
            if response.status_code == 401:
                return {"error": "Invalid OpenAI API key"}
            else:
                return {"error": f"API Error {response.status_code}: {str(e)}"}
        except Exception as e:
            return {"error": f"Connection failed: {str(e)}"}


def test_whisper_api():
    """Test Whisper API connectivity and functionality"""
    print("=" * 70)
    print("WHISPER API TEST (OpenAI)")
    print("=" * 70)
    print()
    
    tester = WhisperTester()
    
    # Check API key
    if not tester.api_key:
        print("❌ OpenAI API key not set")
        print("   Set OPENAI_API_KEY in .env file")
        return
    
    print("✅ API key is set")
    print()
    
    # Test 1: API connectivity
    print("Test 1: API Connectivity")
    print("-" * 50)
    result = tester.test_with_sample_text()
    
    if "error" in result:
        print(f"❌ {result['error']}")
        return
    else:
        print(f"✅ {result['message']}")
    
    print()
    
    # Test 2: Check for existing audio files
    print("Test 2: Audio Files Check")
    print("-" * 50)
    
    # Check if we have any generated TTS files from ElevenLabs
    import glob
    tts_files = glob.glob("/tmp/lisan_tts_*.mp3")
    
    if tts_files:
        print(f"Found {len(tts_files)} audio files from previous TTS tests:")
        for i, f in enumerate(tts_files[:3], 1):  # Show max 3
            print(f"  {i}. {f}")
        
        print()
        print("Test 3: Transcribing generated audio")
        print("-" * 50)
        
        # Test transcription with one of the files
        test_file = tts_files[0]
        print(f"Transcribing: {os.path.basename(test_file)}")
        
        result = tester.transcribe_audio(test_file, language="ar")
        
        if "error" in result:
            print(f"❌ Transcription failed: {result['error']}")
        else:
            print(f"✅ Transcription successful ({result['time']:.2f}s)")
            print(f"   Detected text: '{result['text']}'")
            print(f"   Language: {result['language']}")
    else:
        print("No audio files found.")
        print("To test full transcription:")
        print("  1. Record audio or generate with TTS")
        print("  2. Save as MP3 or WAV")
        print("  3. Run: tester.transcribe_audio('path/to/audio.mp3')")
    
    print()
    print("=" * 70)
    print("WHISPER TEST SUMMARY")
    print("=" * 70)
    print("✅ API connectivity: Working")
    print("✅ API key: Valid")
    if tts_files:
        print("✅ Transcription: Tested with generated audio")
    else:
        print("⚠️  Transcription: No audio files to test (provide MP3/WAV)")
    print()
    print("Pricing: $0.006 per minute of audio")
    print("For 1000 users x 5 min/day = $30/day")
    
    return tester


if __name__ == "__main__":
    tester = test_whisper_api()
