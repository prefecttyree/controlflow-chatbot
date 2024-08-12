from prefect import flow, task
from openai import OpenAI
from pydantic import BaseModel
import streamlit as st
import marvin



@flow(name="is_openai_key_valid")
def is_openai_key_valid(api_key):
    try:
        client = OpenAI(api_key=api_key)
        client.models.list()  # Attempt to list models to check if the key is valid
        print("The OpenAI API key is valid.")
    except Exception as e:
        print("The OpenAI API key is invalid:", e)
        st.error("The OpenAI API key is invalid. Please check your key and try again.", icon="🚫")

@task(name="create_openai_client")
def create_openai_client(api_key):
    client = OpenAI(api_key=api_key)
    return client

@task(name="create_session_state")
def create_session_state():
    if "messages" not in st.session_state:
        st.session_state.messages = []

@flow(name="main")
def main():
    # Show title and description.
    st.title("💬 Chatbot")
    st.write(
        "This is a simple chatbot that uses Marvins model to generate responses. "
        "To use this app, you need to provide an OpenAI API key, which you can get [here](https://platform.openai.com/account/api-keys). "
        "You can also learn how to build this app step by step by [following our tutorial](https://docs.streamlit.io/develop/tutorials/llms/build-conversational-apps)."
    )

    # Ask user for their OpenAI API key via `st.text_input`.
    # Alternatively, you can store the API key in `./.streamlit/secrets.toml` and access it
    # via `st.secrets`, see https://docs.streamlit.io/develop/concepts/connections/secrets-management
    openai_api_key = st.text_input("OpenAI API Key", type="password")
    print(openai_api_key)
    marvin.settings.openai_api_key = openai_api_key
    if not openai_api_key:
        st.info("Please add your OpenAI API key to continue.", icon="🗝️")
        is_openai_key_valid(openai_api_key) 
    else:

        # Create an OpenAI client.
        client = create_openai_client(openai_api_key)

        # Create a session state variable to store the chat messages. This ensures that the
        # messages persist across reruns.
        create_session_state()

        # Display the existing chat messages via `st.chat_message`.
        for message in st.session_state.messages:
            with st.chat_message(message["role"]):
                st.markdown(message["content"])

        # Create a chat input field to allow the user to enter a message. This will display
        # automatically at the bottom of the page.
        if prompt := st.chat_input("What is up?"):

            # Store and display the current prompt.
            st.session_state.messages.append({"role": "user", "content": prompt})
            with st.chat_message("user"):
                st.markdown(prompt)

            # Generate a response using the OpenAI API.
            stream = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": m["role"], "content": m["content"]}
                    for m in st.session_state.messages
                ],
                stream=True,
            )

            # Stream the response to the chat using `st.write_stream`, then store it in 
            # session state.
            with st.chat_message("assistant"):
                response = st.write_stream(stream)
            st.session_state.messages.append({"role": "assistant", "content": response})
            
@flow(name="record_audio") 
def record_audio():
    
    st.write(f"You said: {audio_data}")
    # record the user
    user_audio = mavrin.audio.record_phase()
    audio_data = st.audio_input(user_audio, format="audio/wav", start_time=0, sample_rate=None, end_time=None, loop=False, autoplay=False)
    user_text = marvin.transcribe(user_audio)
    st.write(f"You said: {user_text}")
    
    #cast the language to a more formal style
    ai_text = marvin.cast(user_text, instruction="You are a helpful assistant that speaks in a formal manner.")
    st.write(f"AI said: {ai_text}")
    
    #generate AI speech
    ai_audio = marvin.speak(ai_text)
    
    #play the result
    ai_audio.play()
    
def document_upload():
    pass
    
    
    

            
if __name__ == "__main__":
    main.deploy(name="main",
                work_pool_name="gke-pool", 
                image="DockerImage(image='ghcr.io/marvin-ai/marvin:latest')")
