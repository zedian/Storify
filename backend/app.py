
# coding: utf-8

# In[1]:


from __future__ import absolute_import, division, print_function, unicode_literals
from transformers import GPT2Tokenizer, GPT2LMHeadModel
from flask import Flask,request
import json

app = Flask(__name__)

from flask_cors import CORS
CORS(app)


# In[2]:

import torch
import torch.nn.functional as F


# In[4]:


tokenizer = GPT2Tokenizer.from_pretrained("distilgpt2")
model = GPT2LMHeadModel.from_pretrained("distilgpt2")
model.eval()


# In[5]:


def sample_sequence(
    model,
    length,
    context,
    num_samples=1,
    temperature=1,
    top_k=0,
    top_p=0.9,
    repetition_penalty=1,
    device="cpu",
):

    context = torch.tensor(context)
    context = context.unsqueeze(0).repeat(num_samples, 1)
    generated = context
    with torch.no_grad():
        for _ in range(length):
            inputs = {"input_ids": generated}

            # Get predictions
            outputs = model(
                **inputs
            )
            next_token_logits = outputs[0][0, -1, :] / (temperature if temperature > 0 else 1.0)

            # reptition penalty from CTRL (https://arxiv.org/abs/1909.05858) We have tried this, but the results were too restrictive
            for _ in set(generated.view(-1).tolist()):
                next_token_logits[_] /= repetition_penalty

            filtered_logits = top_k_top_p_filtering(next_token_logits, top_k=top_k, top_p=top_p)
            if temperature == 0:  # greedy sampling:
                next_token = torch.argmax(filtered_logits).unsqueeze(0)
            else:
                next_token = torch.multinomial(F.softmax(filtered_logits, dim=-1), num_samples=1)
            generated = torch.cat((generated, next_token.unsqueeze(0)), dim=1)
    return generated


# In[6]:


def top_k_top_p_filtering(logits, top_k=0, top_p=0.0, filter_value=-float("Inf")):
    """ Filter a distribution of logits using top-k and/or nucleus (top-p) filtering
        Args:
            logits: logits distribution shape (vocabulary size)
            top_k > 0: keep only top k tokens with highest probability (top-k filtering).
            top_p > 0.0: keep the top tokens with cumulative probability >= top_p (nucleus filtering).
                Nucleus filtering is described in Holtzman et al. (http://arxiv.org/abs/1904.09751)
        From: https://gist.github.com/thomwolf/1a5a29f6962089e871b94cbd09daf317
    """
    assert (
        logits.dim() == 1
    )  # batch size 1 for now - could be updated for more but the code would be less clear
    top_k = min(top_k, logits.size(-1))  # Safety check
    if top_k > 0:
        # Remove all tokens with a probability less than the last token of the top-k
        indices_to_remove = logits < torch.topk(logits, top_k)[0][..., -1, None]
        logits[indices_to_remove] = filter_value

    if top_p > 0.0:
        sorted_logits, sorted_indices = torch.sort(logits, descending=True)
        cumulative_probs = torch.cumsum(F.softmax(sorted_logits, dim=-1), dim=-1)

        # Remove tokens with cumulative probability above the threshold
        sorted_indices_to_remove = cumulative_probs > top_p

        # Shift the indices to the right to keep also the first token above the threshold
        sorted_indices_to_remove[..., 1:] = sorted_indices_to_remove[..., :-1].clone()

        sorted_indices_to_remove[..., 0] = 0

        indices_to_remove = sorted_indices[sorted_indices_to_remove]
        logits[indices_to_remove] = filter_value
    return logits


# In[7]:


def predict(text, length):
    print("input text: ", text)
    indexed_tokens = tokenizer.encode(text)
    output = sample_sequence(model, length, indexed_tokens)
    return tokenizer.decode(
        output[0, 0:].tolist(), clean_up_tokenization_spaces=True, skip_special_tokens=True
    )


# In[11]:


@app.route('/',methods=['POST'])
def getgen():
    text = request.form.get('text')
    to_gen = int(len(text)/3)
    generated = {'1': predict(text, to_gen), '2': predict(text, to_gen), '3': predict(text, to_gen)}
    return json.dumps(generated)

# In[13]:


if __name__ == "__main__":
    app.run(host='localhost',port=8021, debug = True)
    

