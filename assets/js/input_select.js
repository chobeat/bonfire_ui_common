let InputSelectHooks = {};

import Tagify from '@yaireo/tagify'

InputSelectHooks.InputOrSelectOne = {

    initInputOrSelectOne() {
        let hook = this,
            $input = hook.el.querySelector("input.tagify"),
            $select = hook.el.querySelector("select.tagify");

        var suggestions = []
        
        Array.from($select.options).forEach(opt => {
            var entry = {};
            entry.value = opt.value;
            entry.text = opt.text;
            suggestions.push(entry);
        });
        console.log("suggestions: ", suggestions)

        suggestionItemTemplate = function(tagData){
            return `
            <div ${this.getAttributes(tagData)}
                class='tagify__dropdown__item ${tagData.class ? tagData.class : ""}'
                tabindex="0"
                role="option">
                <span>${tagData.text}</span>
            </div>
            `
        }

        tagTemplate = function (tagData) {
            return `
            <tag 
                    contenteditable='false'
                    spellcheck='false'
                    tabIndex="-1"
                    class="tagify__tag ${tagData.class ? tagData.class : ""}"
                    ${this.getAttributes(tagData)}>
                <x title='' class='tagify__tag__removeBtn' role='button' aria-label='remove tag'></x>
                <div>
                    <span class='tagify__tag-text'>${tagData.text}</span>
                </div>
            </tag>
            `
        }

        // function onInput(e){
        //     console.log("onInput: ", e.detail);
        //     tagify.whitelist = null; // reset current whitelist
        //     tagify.loading(true) // show the loader animation
        
        //     // get new whitelist from a delayed mocked request (Promise)
            
        //     tagify.settings.whitelist = suggestions.concat(tagify.value) // add already-existing tags to the new whitelist array

        //     tagify
        //     .loading(false)
        //     // render the suggestions dropdown.
        //     .dropdown.show(e.detail.value);
        // }

        const tagify = new Tagify($input, {
            enforceWhitelist: true,
            whitelist: suggestions,
            originalInputValueFormat: valuesArr => valuesArr.map(item => item.value).join(','),
            dropdown: {
                maxItems: 20,           // <- mixumum allowed rendered suggestions
                classname: "tags-look text-slate-800", // <- custom classname for this dropdown, so it could be targeted
                enabled: 0,             // <- show suggestions on focus
                closeOnSelect: true,    // <- do not hide the suggestions dropdown once an item has been selected
                searchKeys: ['text']  // very important to set by which keys to search for suggesttions when typing
                },
            // blacklist: ['foo', 'bar'],
            templates: {
                dropdownItem: suggestionItemTemplate,
                tag: tagTemplate
            },
          })
        //tagify.on('input', onInput)
        },


    mounted() {
        this.initInputOrSelectOne();
    },

    // selected(hook, event) {
    //     let id = event.params.data.id;
    //     hook.pushEvent("country_selected", { country: id })
    // }
}

export { InputSelectHooks }