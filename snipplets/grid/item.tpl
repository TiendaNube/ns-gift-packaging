{# /*============================================================================
  #Item grid
==============================================================================*/

#Properties

#Slide Item

#}

{# Gift Packaging - Leonam Bernini #}
{% set is_gift_item =  settings.lb_gift_packaging and product.id == settings.lb_gift_packaging_product %}

{% if not is_gift_item %}

    {% set slide_item = slide_item | default(false) %}
    {% set columns = settings.grid_columns %}
    {% set has_color_variant = false %}
    {% if settings.product_color_variants %}
        {% for variation in product.variations if variation.name in ['Color', 'Cor'] and variation.options | length > 1 %}
            {% set has_color_variant = true %}
        {% endfor %}
    {% endif %}

    <div class="js-item-product {% if slide_item %}js-item-slide swiper-slide{% else %}col{% if columns == 2 %}-6 col-md-3{% else %}-12 col-md-4{% endif %}{% endif %} item item-product{% if not product.display_price %} no-price{% endif %}" data-product-type="list" data-product-id="{{ product.id }}" data-store="product-item-{{ product.id }}">

        {% if settings.quick_shop or settings.product_color_variants %}
            <div class="js-product-container js-quickshop-container {% if product.variations %}js-quickshop-has-variants{% endif %}" data-variants="{{ product.variants_object | json_encode }}" data-quickshop-id="quick{{ product.id }}{% if slide_item and section_name %}-{{ section_name }}{% endif %}">
        {% endif %}

            {% set product_url_with_selected_variant = has_filters ?  ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url  %}

            {% if has_color_variant %}

                {# Item image will be the first avaiable variant #}

                {% set item_img_spacing = product.featured_variant_image.dimensions['height'] / product.featured_variant_image.dimensions['width'] * 100 %}
                {% set item_img_srcset = product.featured_variant_image %}
                {% set item_img_alt = product.featured_variant_image.alt %}
            {% else %}

                {# Item image will be the first image regardless the variant #}

                {% set item_img_spacing = product.featured_image.dimensions['height'] / product.featured_image.dimensions['width'] * 100 %}
                {% set item_img_srcset = product.featured_image %}
                {% set item_img_alt = product.featured_image.alt %}
            {% endif %}

            <div class="item-image mb-2">
                <div style="padding-bottom: {{ item_img_spacing }}%;" class="p-relative" data-store="product-item-image-{{ product.id }}">
                    <a href="{{ product_url_with_selected_variant }}" title="{{ product.name }}">
                        <img alt="{{ item_img_alt }}" data-sizes="auto" data-expand="-10" src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset="{{ item_img_srcset | product_image_url('small')}} 240w, {{ item_img_srcset | product_image_url('medium')}} 320w, {{ item_img_srcset | product_image_url('large')}} 480w" class="js-item-image lazyautosizes lazyload img-absolute img-absolute-centered fade-in" /> 
                        <div class="placeholder-fade"></div>
                    </a>
                    {% if settings.product_color_variants %}
                        {% include 'snipplets/labels.tpl' with {color: true} %}
                        {% include 'snipplets/grid/item-colors.tpl' %}
                    {% else %}
                        {% include 'snipplets/labels.tpl' %}
                    {% endif %}
                </div>
            </div>
            {% if (settings.quick_shop or settings.product_color_variants) and product.variations %}

                {# Hidden product form to update item image and variants: Also this is used for quickshop popup #}
                
                <div class="js-item-variants hidden">
                    <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                        {% if product.variations %}
                            {% include "snipplets/product/product-variants.tpl" with {quickshop: true} %}
                        {% endif %}
                        {% if product.available and product.display_price and settings.quick_shop %}
                            {% include "snipplets/product/product-quantity.tpl" with {quickshop: true} %}
                        {% endif %}
                        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                        {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                        {# Add to cart CTA #}

                        <input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-block {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} />

                        {# Fake add to cart CTA visible during add to cart event #}

                        {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "btn-block"} %}

                    </form>
                </div>

            {% endif %}
            <div class="item-description" data-store="product-item-info-{{ product.id }}">
                <a href="{{ product_url_with_selected_variant }}" title="{{ product.name }}" class="item-link">
                    <div class="js-item-name item-name mb-1" data-store="product-item-name-{{ product.id }}">{{ product.name }}</div>
                    {% if product.display_price %}
                        <div class="item-price-container mb-1" data-store="product-item-price-{{ product.id }}">
                            <span class="js-compare-price-display price-compare" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %}>
                                {{ product.compare_at_price | money }}
                            </span>
                            <span class="js-price-display item-price">
                                {{ product.price | money }}
                            </span>

                        </div>
                    {% endif %}
                </a>
            </div>
            {% include 'snipplets/payments/installments.tpl' %}

            {% if settings.quick_shop and product.available and product.display_price %}

                {# Trigger quickshop actions #}
                
                <div class="item-actions mt-2">
                    {% if product.variations %}

                        {# Open quickshop popup if has variants #}

                        <a data-toggle="#quickshop-modal" data-modal-url="modal-fullscreen-quickshop" class="js-quickshop-modal-open {% if slide_item %}js-quickshop-slide{% endif %} js-modal-open js-fullscreen-modal-open btn btn-primary btn-small px-4" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}" >{{ 'Agregar al carrito' | translate }}</a>
                    {% else %}

                        {# If not variants add directly to cart #}
                        <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                            <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                            {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                            {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                            <input type="number" name="quantity" value="1" class="js-quantity-input hidden" aria-label="{{ 'Cambiar cantidad' | translate }}" >

                            <input type="submit" class="js-addtocart js-prod-submit-form btn btn-primary btn-small {{ state }} px-4 mb-1" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} />

                            {# Fake add to cart CTA visible during add to cart event #}

                            {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "js-addtocart-placeholder-inline btn-small mb-1"} %}

                        </form>
                    {% endif %}
                </div>
            {% endif %}

            {# Structured data to provide information for Google about the product content #}
            {% include 'snipplets/structured_data/item-structured-data.tpl' %}
        {% if settings.quick_shop or settings.product_color_variants %}
            </div>
        {% endif %}
    </div>
{% endif %}