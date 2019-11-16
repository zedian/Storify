model = GPT2LMHeadModel.from_pretrained("distilgpt2")
model.eval()

# download the tokenizer
tokenizer = GPT2Tokenizer.from_pretrained("distilgpt2")

def init(model_path, metadata):
    # load the model onto the device specified in the metadata field of our api configuration
    model.to(metadata["device"])

def predict(sample, metadata):
    indexed_tokens = tokenizer.encode(sample["text"])
    output = sample_sequence(model, metadata['num_words'], indexed_tokens, device=metadata['device'])
    return tokenizer.decode(
        output[0, 0:].tolist(), clean_up_tokenization_spaces=True, skip_special_tokens=True
    )
